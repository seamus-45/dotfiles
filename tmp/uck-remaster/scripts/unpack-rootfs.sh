#!/bin/bash
[[ -d squashfs ]] && rm -rf squashfs || mkdir -vp squashfs
[[ -d chroot ]] && rm -rf chroot || mkdir -vp chroot
if [ -f image/casper/filesystem.squashfs ]; 
then
  mount -v -t squashfs -o loop image/casper/filesystem.squashfs squashfs
  echo -n 'Unpack squashfs... '
  cp -a squashfs/* chroot && echo 'done'
  umount -v squashfs
  rmdir -v squashfs
else
  echo -e "Please unpack iso before unpack rootfs\n"
  exit 1
fi

