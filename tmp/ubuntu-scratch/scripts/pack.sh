#!/bin/bash
./pack-rootfs.sh && ./pack-iso.sh && mv -v ubuntu-remix.iso /home/fedotov_sv/downloads/iso/ubuntu/ubuntu-14.04-i686-taxi-$(date +%Y%m%d).iso
