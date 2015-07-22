xrdb -load ~/.Xresources

# fonts
xset +fp ~/.fonts
xset +fp /usr/share/fonts/terminus/
xset fp rehash 

# fix bug with java apps
wmname LG3D

# appearance
xsetroot -cursor_name left_ptr &
#hsetroot -tile $HOME/.config/bspwm/tinytile2.gif &
#hsetroot -tile $HOME/pictures/main/wallhaven-51214-0-0.jpg &
# just for fun
mpv -ao null --wid=0 --loop=inf ~/media/loops/AmazonSwamp.mov --panscan=0.6 &

# save my eyes
#redshift -l 49.26:-123.23 &

# screen locker
xset s 180

# turn on num lock
numlockx

# auto mounts USB to /media/
# udiskie &

# bind side buttons
imwheel -k -b 000089

# start dunst notify daemon
dunst &

# clipman
parcellite &

# start music player daemon
mpd &

# polkit (for virt-manager gui)
/usr/libexec/polkit-gnome-authentication-agent-1 &

# run WM
#compton &
sxhkd &
exec dbus-launch --exit-with-session --sh-syntax bspwm
