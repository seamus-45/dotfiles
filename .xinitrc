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
hsetroot -tile $HOME/pictures/main/wallpaper-2723732.png &
# save my eyes
#redshift -l 49.26:-123.23 &

# screen locker
xset s 180

# Auto mounts USB to /media/
# udiskie &

# bind side buttons
imwheel -k -b 000089

# start dunst notify daemon
dunst &

# clipman
parcellite &

# run WM
compton &
sxhkd &

exec bspwm
