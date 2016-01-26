#!/bin/sh
if [ $# -lt 1 ];
then
  debootstrap --help
  exit
fi

source ../scripts/functions.sh

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
#deb http://extras.ubuntu.com/ubuntu codename main
#deb http://archive.canonical.com/ubuntu/ codename partner
EOF
)

ebegin "making clean environment"
	[[ -d chroot ]] && rm -rf chroot || mkdir chroot
	[[ -d image ]] && rm -rf image || mkdir image
eend $?

ebegin "deboostrap"
	debootstrap --arch=amd64 $@ chroot http://archive.ubuntu.com/ubuntu > /dev/null
eend $?

# bind systems
mountfs "chroot/dev"
mountfs "chroot/proc"
mountfs "chroot/sys"

ebegin "deploy sources.list"
	RELEASE=`chroot chroot lsb_release -c | cut -f2`
	echo "${SOURCES}" | sed "s/codename/${RELEASE}/" > chroot/etc/apt/sources.list
eend $?

ebegin "import extras GPG key"
	{
	chroot chroot apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192 && \
  chroot chroot apt-get update
	} >/dev/null 2>/dev/null
eend $?

ebegin "divert initctl (fix upstart bug)"
	chroot chroot /usr/bin/dpkg-divert --quiet --local --rename --add /sbin/initctl
	ln -s /bin/true chroot/sbin/initctl
eend $?

ebegin "divert invoke-rc.d (fix apt-get bug with PI-scripts)"
	chroot chroot /usr/bin/dpkg-divert --quiet --local --rename --add /usr/sbin/invoke-rc.d
	ln -s /bin/true chroot/usr/sbin/invoke-rc.d
eend $?

ebegin "divert resolv.conf (set dns from host system)"
	chroot chroot /usr/bin/dpkg-divert --quiet --local --rename --add /etc/resolv.conf
	cp /etc/resolv.conf chroot/etc
eend $?

ebegin "install dbus and generate dbus uuid"
	{
	chroot chroot apt-get --yes install dbus
	chroot chroot dbus-uuidgen > /var/lib/dbus/machine-id
	} >/dev/null 2>/dev/null
eend $?

ebegin "installing base packages"
	{
	chroot chroot apt-get install --yes ubuntu-standard casper lupin-casper
	chroot chroot apt-get install --yes discover laptop-detect os-prober
	chroot chroot apt-get install --yes linux-generic
	chroot chroot apt-get install --yes memtest86+
	} >/dev/null 2>/dev/null
eend $?

ebegin "copy files needed for bootable ISO"
	mkdir -p image/{casper,isolinux,install,.disk}
	cp chroot/boot/vmlinuz-*.**.**-**-generic image/casper/vmlinuz
	cp chroot/boot/initrd.img-*.**.**-**-generic image/casper/initrd.gz
	cp /usr/share/syslinux/isolinux.bin image/isolinux/
	cp /usr/share/syslinux/ldlinux.c32 image/isolinux/
	cp /usr/share/syslinux/chain.c32 image/isolinux/
	cp /usr/share/syslinux/libcom32.c32 image/isolinux
	cp /usr/share/syslinux/libutil.c32 image/isolinux
	cp chroot/boot/memtest86+.bin image/install/memtest
eend $?

ebegin "create disk defines"
echo -e "#define DISKNAME  Ubuntu Remix\n#define TYPE  binary\n#define TYPEbinary  1\n#define ARCH  i386\n#define ARCHi386  1\n#define DISKNUM  1\n#define DISKNUM1  1\n#define TOTALNUM  0\n#define TOTALNUM0  1" > image/README.diskdefines
touch image/ubuntu
touch image/.disk/base_installable
echo "full_cd/single" > image/.disk/cd_type
echo "Ubuntu Remix" > image/.disk/info
echo "http//your-release-notes-url.com" > image/.disk/release_notes_url
eend $?

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
	rm -rf chroot/tmp/*
	rm -f chroot/var/log/apt/*
	rm -rf chroot/var/cache/apt/archives/*
	rm -f chroot/var/lib/dbus/machine-id
eend $?

ebegin "unbind filesystems"
	umount -l chroot/sys
	umount -l chroot/proc
	umount -l chroot/dev
eend $?
