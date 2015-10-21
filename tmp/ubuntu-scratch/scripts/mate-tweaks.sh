#!/bin/bash
if [ ! -d "chroot/etc/mdm" ] && [ ! -x "chroot/usr/bin/mate-session" ];
then
  echo "Mate not installed. Tweaks failed."
  exit 0
fi

#change default gtk-3.0 settings
sed -i -e 's/Ambiance/Menta/' \
  -e 's/ubuntu-mono-dark/menta/' \
  chroot/etc/gtk-3.0/settings.ini
#change default background
sed -i -e 's/edubuntu_default\.png/mate\/desktop\/Stripes.png/' chroot/usr/bin/ubiquity-dm
#fix ubiquity-dm to use marco
sed -i -e "s@'metacity@'marco@g" chroot/usr/bin/ubiquity-dm
#fix upstart to start ubiquity after mdm
sed -i 's/gdm/mdm/g' chroot/etc/init/ubiquity.conf
#fix mdm.conf to support casper autologin hack
sed -i '/\(Automatic\|Timed\)Login/d' chroot/etc/mdm/mdm.conf
sed -i "s/\[daemon\]/\[daemon\]\n\# AutomaticLoginEnable =\n\# AutomaticLogin =\n\# TimedLoginEnable =/" chroot/etc/mdm/mdm.conf
#fix casper script for autologin to live session
mkdir -p initrd
pushd initrd >/dev/null
gunzip -dc ../image/casper/initrd.gz | cpio -imvd --no-absolute-filenames

sed -i -r -e 's/GDMCustomFile/MDMCustomFile/' \
  -e 's/GDM/MDM/' \
  -e 's/gdm\/custom.conf/mdm\/mdm.conf/' \
  scripts/casper-bottom/15autologin

find . | cpio -o -H newc | gzip -9 > ../image/casper/initrd.gz
popd >/dev/null
rm -rf initrd

#fix ubiquity script, for autologin to target system if user select this
sed -i -r -e 's/etc\/gdm/etc\/mdm/' \
  -e 's/custom\.conf/mdm.conf/' \
  -e 's/GDM/MDM/' \
  chroot/usr/lib/ubiquity/user-setup/user-setup-apply

#fix ubiquity desktop file to be shown in mate
if [ -e 'chroot/usr/share/applications/ubiquity-gtkui.desktop' ];
then
  sed -i '/OnlyShowIn/d' chroot/usr/share/applications/ubiquity-gtkui.desktop
  echo -e "OnlyShowIn=MATE;\n" >> chroot/usr/share/applications/ubiquity-gtkui.desktop
fi

#fix vino autostart issue
if [ -e 'chroot/etc/xdg/autostart/vino-server.desktop' ];
then
  sed -i -e 's/GNOME/MATE/g' chroot/etc/xdg/autostart/vino-server.desktop
fi
if [ -e 'chroot/usr/share/applications/vino-preferences.desktop' ];
then
  sed -i -e 's/GNOME/MATE/g' chroot/usr/share/applications/vino-preferences.desktop
fi
