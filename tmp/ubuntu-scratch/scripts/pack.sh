#!/bin/bash
./pack-rootfs.sh && \
./pack-iso.sh || exit 1
SIZE=$(du -csh ubuntu-remix.iso | head -n1 | cut -f1)
REL=$(chroot chroot lsb_release -rs)
ARCH=$(chroot chroot arch)

read -n1 -p "Move to ISO folder? (y,n)" choice
echo -ne '\n'
case $choice in
	[yY])
		mv -v ubuntu-remix.iso /home/fedotov_sv/downloads/iso/ubuntu/ubuntu-${REL}-${ARCH}-taxi-$(date +%Y%m%d).iso
		ln -sf ubuntu-${REL}-${ARCH}-taxi-$(date +%Y%m%d).iso /home/fedotov_sv/downloads/iso/ubuntu/ubuntu-${REL}-${ARCH}-taxi-latest.iso
		;;
	*)
		;;
esac

echo "Size: $SIZE"
