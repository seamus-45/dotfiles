#!/bin/bash
source ../scripts/functions.sh

ebegin "generating filesystem manifest"
	chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | tee image/casper/filesystem.manifest > /dev/null && \
	cp image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
eend $?

REMOVE='ubiquity ubiquity-frontend-gtk ubiquity-frontend-kde ubiquity-frontend-debconf casper lupin-casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4'
for i in $REMOVE
do
  sed -i "/${i}/d" image/casper/filesystem.manifest-desktop
done

ebegin "calculating filesystem size"
	du -sx --block-size=1 chroot | cut -f1 > image/casper/filesystem.size
eend $?

cd image

ebegin "calculating md5 sums"
	find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt
eend $?

ebegin "generating iso"
  ver=$(chroot ../chroot lsb_release -sir | paste -s -d' ')
	mkisofs -quiet -r -V "${ver}" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../ubuntu-remix.iso .
eend $?

cd ..
