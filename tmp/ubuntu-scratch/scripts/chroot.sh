#!/bin/bash
source ../scripts/functions.sh

mountfs() {
	mountpoint $1 >/dev/null
	if [[ $? -ne 0 ]];
	then
		ebegin "mounting $1"
		mount -o rbind /${1#*/} $1
		eend $?
	else
		ebegin "filesystem $1 is already mounted"
		eend 0
	fi
}

mountfs "chroot/dev"
mountfs "chroot/proc"
mountfs "chroot/sys"

ebegin "divert initctl (fix upstart bug)"
	chroot chroot /usr/bin/dpkg-divert --quiet --local --rename --add /sbin/initctl
	ln -s /bin/true chroot/sbin/initctl
eend $?

ebegin "divert invoke-rc.d (fix apt-get bug with PI-scripts)"
	chroot chroot /usr/bin/dpkg-divert --quiet --local --rename --add /usr/sbin/invoke-rc.d
	cp invoke-rc.d-421 chroot/usr/sbin/invoke-rc.d
eend $?

ebegin "divert resolv.conf (set dns from host system)"
	chroot chroot /usr/bin/dpkg-divert --quiet --local --rename --add /etc/resolv.conf
	cp /etc/resolv.conf chroot/etc
eend $?

ebegin "generate dbus machine id"
	chroot chroot /bin/dbus-uuidgen > /var/lib/dbus/machine-id
eend $?

echo -e "\nEntering chroot\n"
chroot chroot /usr/bin/env -i \
	LC_ALL=ru_RU.utf-8 \
  HOME=/root \
  TERM="$TERM" \
  PS1='\u:\w\$ ' \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/bash --login +h

# clean and restore
ebegin "restore initctl"
	rm -f chroot/sbin/initctl
	chroot chroot /usr/bin/dpkg-divert --quiet --rename --remove /sbin/initctl
eend $?

ebegin "restore invoke-rc.d"
	rm -f chroot/usr/sbin/invoke-rc.d
	chroot chroot /usr/bin/dpkg-divert --quiet --rename --remove /usr/sbin/invoke-rc.d
eend $?

ebegin "restore resolv.conf"
	rm -f chroot/etc/resolv.conf
	chroot chroot /usr/bin/dpkg-divert --quiet --rename --remove /etc/resolv.conf
eend $?

ebegin "clean temporary stuff"
	find chroot/usr/share/icons -type f -name icon-theme.cache -delete
	rm -rf chroot/tmp/*
	rm -f chroot/root/.bash_history
	rm -f chroot/var/log/apt/*
	rm -rf chroot/var/cache/apt/archives/*
	rm -f chroot/var/lib/dbus/machine-id
eend $?

ebegin "unbind filesystems"
	umount -l chroot/sys
	umount -l chroot/proc
	umount -l chroot/dev
eend $?

