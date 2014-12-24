#!/bin/bash
SOURCE=../remaster-apt-cache/archives/
DEST=chroot/var/cache/apt/archives/
function chkdir {
if [ ! -d ${1} ];
then
  echo "Directory ${1} does not exists!"
  exit 1
fi
}
chkdir ${SOURCE}
chkdir ${DEST}
mountpoint ${DEST} >/dev/null; [[ $? -ne 0 ]] && mount -v -o bind ${SOURCE} ${DEST}
mountpoint chroot/dev >/dev/null; [[ $? -ne 0 ]] && mount -v -o rbind /dev chroot/dev
mountpoint chroot/proc >/dev/null; [[ $? -ne 0 ]] && mount -v -o bind /proc chroot/proc
mountpoint chroot/sys >/dev/null; [[ $? -ne 0 ]] && mount -v -o bind /sys chroot/sys

# divert initctl (fix upstart bug)
cp -v chroot/sbin/initctl chroot/root/initctl
chroot chroot /usr/bin/dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true chroot/sbin/initctl

chroot chroot /bin/dbus-uuidgen > /var/lib/dbus/machine-id

chroot chroot /usr/bin/env -i \
  LC_ALL=C \
  HOME=/root \
  TERM="$TERM" \
  PS1='\u:\w\$ ' \
  PATH=/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/bash --login +h

# clean and restore
find chroot/usr/share/icons -type f -name icon-theme.cache -delete
rm -vrf chroot/tmp/*
rm -vf chroot/sbin/initctl
chroot chroot /usr/bin/dpkg-divert --rename --remove /sbin/initctl
[[ -f chroot/sbin/initctl ]] && echo 'initctl was restored successfully' || cp -vf chroot/root/initctl chroot/sbin/initctl
rm -vf chroot/root/initctl
rm -vf chroot/root/.bash_history
rm -vf chroot/var/lib/dbus/machine-id
rm -vf chroot/var/log/apt/*

#umount all
umount -v -l chroot/dev
umount -v -l chroot/proc
umount -v -l chroot/sys
umount -v -l ${DEST}

