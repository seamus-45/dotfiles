#!/bin/bash
source ../scripts/functions.sh

if [[ $# -ne 1 ]]; then
  echo 'Please specify iso file to unpack.'
  exit 1
fi

if [[ -f "$1" ]]; then
	ebegin "prepare environment for unpacking iso"
		[[ -d image ]] && rm -rf image || mkdir -pv image
		[[ ! -d iso ]] && mkdir -v iso
	eend $?
	ebegin "mount iso over loop"
		mount -v -o loop "$1" iso
	eend $?
  ebegin "extract iso content"
		cp -a iso/* image/
	eend $?
	ebegin "umount iso and clean"
		umount -v iso
		rm -rfv iso
	eend $?
fi
