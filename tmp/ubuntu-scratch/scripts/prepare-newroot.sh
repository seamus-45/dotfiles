#!/bin/sh
if [ $# -lt 1 ];
then
  debootstrap --help
  exit
fi

SOURCES=$(cat << "EOF"
deb http://ru.archive.ubuntu.com/ubuntu/ codename main restricted
deb http://ru.archive.ubuntu.com/ubuntu/ codename-updates main restricted
deb http://security.ubuntu.com/ubuntu codename-security main restricted
deb http://ru.archive.ubuntu.com/ubuntu/ codename universe
deb http://ru.archive.ubuntu.com/ubuntu/ codename-updates universe
deb http://ru.archive.ubuntu.com/ubuntu/ codename multiverse
deb http://ru.archive.ubuntu.com/ubuntu/ codename-updates multiverse
deb http://ru.archive.ubuntu.com/ubuntu/ codename-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu codename-security universe
deb http://security.ubuntu.com/ubuntu codename-security multiverse
deb http://extras.ubuntu.com/ubuntu codename main
deb http://archive.canonical.com/ubuntu/ codename partner
EOF
)

# make clean environment
[[ -d chroot ]] && rm -rf chroot
[[ -d image ]] && rm -rf image
mkdir -p chroot/var/cache/apt/archives/partial
mount -v -o bind ../remaster-apt-cache/archives chroot/var/cache/apt/archives
[[ $? -eq 0 ]] && echo '/var/apt/cache/archives bind successful.'
debootstrap --arch=amd64 $@ chroot http://archive.ubuntu.com/ubuntu

[[ $? -ne 0 ]] && exit $?

# bind systems
mount -v -o rbind /dev chroot/dev
[[ $? -eq 0 ]] && echo '/dev bind successful.'
mount -v -o bind /proc chroot/proc
[[ $? -eq 0 ]] && echo '/proc bind successful.'
mount -v -o bind /sys chroot/sys
[[ $? -eq 0 ]] && echo '/sys bind successful.'

# deploy sources.list file
RELEASE=`chroot chroot lsb_release -c | cut -f2`
echo "${SOURCES}" | sed "s/codename/${RELEASE}/" > chroot/etc/apt/sources.list

# import extras gpg key
chroot chroot apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192
chroot chroot apt-get update

# divert initctl (fix upstart bug)
cp -v chroot/sbin/initctl chroot/root/initctl
chroot chroot /usr/bin/dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true chroot/sbin/initctl

# install dbus if not installed and generate uuid
chroot chroot apt-get --yes install dbus
chroot chroot /bin/dbus-uuidgen > /var/lib/dbus/machine-id

# install other necessary packages
chroot chroot apt-get install --yes ubuntu-standard casper lupin-casper
chroot chroot apt-get install --yes discover laptop-detect os-prober
chroot chroot apt-get install --yes linux-generic
chroot chroot apt-get install --yes memtest86+

# copy important binaries
mkdir -p image/{casper,isolinux,install,.disk}
cp -v chroot/boot/vmlinuz-3.**.**-**-generic image/casper/vmlinuz
cp -v chroot/boot/initrd.img-3.**.**-**-generic image/casper/initrd.gz
cp -v /usr/share/syslinux/isolinux.bin image/isolinux/
cp -v chroot/boot/memtest86+.bin image/install/memtest

# create disk defines
echo -e "#define DISKNAME  Ubuntu Remix\n#define TYPE  binary\n#define TYPEbinary  1\n#define ARCH  i386\n#define ARCHi386  1\n#define DISKNUM  1\n#define DISKNUM1  1\n#define TOTALNUM  0\n#define TOTALNUM0  1" > image/README.diskdefines
touch image/ubuntu
touch image/.disk/base_installable
echo "full_cd/single" > image/.disk/cd_type
echo "Ubuntu Remix" > image/.disk/info
echo "http//your-release-notes-url.com" > image/.disk/release_notes_url

# restore initctl
rm -vf chroot/var/lib/dbus/machine-id
rm -vf chroot/sbin/initctl
chroot chroot /usr/bin/dpkg-divert --rename --remove /sbin/initctl
[[ -f chroot/sbin/initctl ]] && echo 'initctl was restored successfully' || cp -vf chroot/root/initctl chroot/sbin/initctl
rm -vf chroot/root/initctl

# unbind archives
umount -v -l chroot/var/cache/apt/archives
umount -v -l chroot/dev
umount -v -l chroot/proc
umount -v -l chroot/sys

