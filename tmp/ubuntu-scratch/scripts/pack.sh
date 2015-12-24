#!/bin/bash
./pack-rootfs.sh && \
./pack-iso.sh || exit 1
SIZE=$(du -csh ubuntu-remix.iso | head -n1 | cut -f1)
#mv -v ubuntu-remix.iso /home/fedotov_sv/downloads/iso/ubuntu/ubuntu-14.04-i686-taxi-$(date +%Y%m%d).iso
echo "Size: $SIZE"
