#!/bin/bash
source ../scripts/functions.sh

ebegin "prepare environment to unpack rootfs"
	[[ -d squashfs ]] && rm -rf squashfs || mkdir -vp squashfs
	[[ -d chroot ]] && rm -rf chroot || mkdir -vp chroot
eend $?
if [ -f image/casper/filesystem.squashfs ]; 
then
	ebegin "mount squashfs image over loop"
		mount -v -t squashfs -o loop image/casper/filesystem.squashfs squashfs
	eend $?
	ebegin "extract rootfs content"
		cp -a squashfs/* chroot && echo 'done'
	eend $?
	ebegin "umount rootfs and clean"
		umount -v squashfs
		rmdir -v squashfs
	eend $?
else
  echo -e "Please unpack iso before unpack rootfs\n"
  exit 1
fi

