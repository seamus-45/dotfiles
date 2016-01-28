#!/bin/bash
PROXY=$(cat << "EOF"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
http_proxy="http://proxy.kurgan.taximaxim.ru:3131/"
https_proxy="https://proxy.kurgan.taximaxim.ru:3131/"
ftp_proxy="ftp://proxy.kurgan.taximaxim.ru:3131/"
socks_proxy="socks://proxy.kurgan.taximaxim.ru:3131/"
no_proxy="localhost,127.0.0.0/8,*.local,10.0.0.0/8,taximaxim.ru,taxsee.ru"
EOF
)

echo "${PROXY}" > chroot/etc/environment

PROXY=$(cat << "EOF"
Acquire::http::proxy "http://proxy.kurgan.taximaxim.ru:3131/";
Acquire::https::proxy "https://proxy.kurgan.taximaxim.ru:3131/";
Acquire::ftp::proxy "ftp://proxy.kurgan.taximaxim.ru:3131/";
Acquire::socks::proxy "socks://proxy.kurgan.taximaxim.ru:3131/";
EOF
)

echo "${PROXY}" > chroot/etc/apt/apt.conf

# disable ubiquity panel
# sed -i 's/"openbox" not in wm_cmd/"marco" not in wm_cmd/' chroot/usr/bin/ubiquity-dm 

# disable user account creation
sed -i 's/make-user true/make-user false/' chroot/usr/lib/ubiquity/user-setup/user-setup-ask

# fix automatic time zone detection
if ! `grep -qs '"timezone"' chroot/usr/lib/ubiquity/tzsetup/tzsetup`;
then
	patch -p0 -i ../patches/tzdetect-ip-api.com.patch 
fi
