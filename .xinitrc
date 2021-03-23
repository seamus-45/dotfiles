xrdb -load ~/.Xresources

# fonts
xset +fp ~/.fonts
xset +fp /usr/share/fonts/terminus/
xset fp rehash

# fix bug with java apps
wmname LG3D

# appearance
xsetroot -cursor_name left_ptr &
hsetroot -root -fill $(cat ~/.config/bspwm/wallpaper) &
# just for fun
# mpv -ao null --wid=0 --loop=inf ~/media/loops/AmazonSwamp.mov --panscan=0.6 &

# save my eyes
redshift -l 55.420898:65.273957 &

# screen locker
xset s off

# dpms settings (standby|suspend|off)
xset dpms 300 600 1200

# turn on num lock
numlockx

# auto mounts USB to /media/
# udiskie &

# bind side buttons
imwheel -k -b 000089

# polkit (for virt-manager gui)
#/usr/libexec/polkit-gnome-authentication-agent-1 &

# run WM
#picom --experimental-backends &
picom  &
exec dbus-launch --exit-with-session bspwm
