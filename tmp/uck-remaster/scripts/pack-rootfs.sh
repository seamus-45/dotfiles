#!/bin/bash
[[ -x ./tweaks.sh ]] && ./tweaks.sh

#pack squashfs
mksquashfs chroot image/casper/filesystem.squashfs -noappend 
