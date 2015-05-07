#!/bin/bash
SOURCE=/home/fedotov_sv/tmp/uck-remaster/remaster-apt-cache/archives/
DEST=/var/cache/apt/archives/

# divert initctl (fix upstart bug)
chroot chroot /usr/bin/dpkg-divert --local --rename --add /sbin/initctl
ln -sv /bin/true chroot/sbin/initctl

# divert invoke-rc.d (fix apt-get bug with PI-scripts)
chroot chroot /usr/bin/dpkg-divert --local --rename --add /usr/sbin/invoke-rc.d
cp -v invoke-rc.d-421 chroot/usr/sbin/invoke-rc.d

# divert resolv.conf (make internet)
chroot chroot /usr/bin/dpkg-divert --local --rename --add /etc/resolv.conf
cp -v /etc/resolv.conf chroot/etc

# make dbus machine id
chroot chroot /bin/dbus-uuidgen > /var/lib/dbus/machine-id

# spawn container
systemd-nspawn -D chroot --bind ${SOURCE}:${DEST} --setenv=LC_ALL=C /bin/bash

# clean and restore
rm -vf chroot/sbin/initctl
chroot chroot /usr/bin/dpkg-divert --rename --remove /sbin/initctl

rm -vf chroot/usr/sbin/invoke-rc.d
chroot chroot /usr/bin/dpkg-divert --rename --remove /usr/sbin/invoke-rc.d

rm -vf chroot/etc/resolv.conf
chroot chroot /usr/bin/dpkg-divert --rename --remove /etc/resolv.conf

rm -vf chroot/var/lib/dbus/machine-id

find chroot/usr/share/icons -type f -name icon-theme.cache -delete
rm -vrf chroot/tmp/*
rm -vf chroot/root/.bash_history
rm -vf chroot/var/log/apt/*
