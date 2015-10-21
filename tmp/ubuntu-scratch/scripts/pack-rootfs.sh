#!/bin/bash
source ../scripts/functions.sh

if [[ -x ./tweaks.sh ]];
then
	ebegin "make tweaks"
	./tweaks.sh
	eend $?
fi

ebegin "pack rootfs"
	mksquashfs chroot image/casper/filesystem.squashfs -noappend -no-progress >/dev/null
eend $?
