#!/bin/bash
#calculate md5sums
echo -n 'Generating filesystem manifest... '
$(chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | tee image/casper/filesystem.manifest > /dev/null) && echo 'done'
cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
REMOVE='ubiquity ubiquity-frontend-gtk ubiquity-frontend-kde ubiquity-frontend-debconf casper lupin-casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4'
for i in $REMOVE
do
  sed -i "/${i}/d" image/casper/filesystem.manifest-desktop
done
echo -n 'Calculating filesystem size... '
$(du -sx --block-size=1 chroot | cut -f1 > image/casper/filesystem.size) && echo 'done'
pushd image >/dev/null
find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt

#create iso image
echo -n 'Generating iso... '
$(mkisofs -quiet -r -V "Ubuntu Remix" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../ubuntu-remix.iso .) && echo 'done'
popd >/dev/null
echo -n 'Size: '
du -csh ubuntu-remix.iso | head -n1 | cut -f1
