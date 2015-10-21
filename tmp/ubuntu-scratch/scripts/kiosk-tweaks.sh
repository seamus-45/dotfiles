#!/bin/bash
#change default gtk-3.0 settings
sed -i -e 's/Ambiance/Adwaita/' \
  -e 's/ubuntu-mono-dark/gnome/' \
  chroot/etc/gtk-3.0/settings.ini
#change default ubi background
sed -i -e 's/backgrounds\/edubuntu_default\.png/themes\/Adwaita\/backgrounds\/morning.jpg/' chroot/usr/bin/ubiquity-dm
#fix ubiquity-dm to use awesome
sed -i -e "s@matchbox-window-manager@awesome@g" chroot/usr/bin/ubiquity-dm
#fix upstart to start ubiquity after slim
sed -i 's/gdm/slim/g' chroot/etc/init/ubiquity.conf
#fix casper script for autologin to live session
mkdir -p initrd
pushd initrd >/dev/null
echo -n 'Extracting initrd... '
$(gunzip -dc ../image/casper/initrd.gz | cpio -imvd --no-absolute-filenames 2>/dev/null) && echo 'done'

SCRIPT=$(cat << "EOF"
if [ -f /root/etc/slim.conf ]; then
  sed -i -e 's/^\#\?\(auto_login\).*$/\1\tyes/' -e "s/^\#\?\(default_user\).*$/\1\t$USERNAME/" /root/etc/slim.conf
fi

log_end_msg
EOF
)

if ! `grep -qs 'slim' scripts/casper-bottom/15autologin`; then
  sed -i -e '/^log_end_msg/d' scripts/casper-bottom/15autologin
  echo "${SCRIPT}" >> scripts/casper-bottom/15autologin
fi

echo -n 'Compressing initrd... '
$(find . | cpio -o -H newc 2>/dev/null | gzip -9 > ../image/casper/initrd.gz) && echo 'done'
popd >/dev/null
rm -rf initrd

#fix ubiquity script, for autologin to target system if user select this
if ! `grep -qs 'slim' chroot/usr/lib/ubiquity/user-setup/user-setup-apply`;
then
  pushd chroot/usr/lib/ubiquity/user-setup/ >/dev/null
  patch -p0 -i ../../../../../../patches/ubiquity-slim.patch
  popd >/dev/null
fi

