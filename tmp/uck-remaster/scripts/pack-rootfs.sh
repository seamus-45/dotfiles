#!/bin/bash
./tweaks.sh

#pack squashfs
mksquashfs chroot image/casper/filesystem.squashfs -noappend | head -n3
