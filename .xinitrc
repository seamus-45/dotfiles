#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb -merge ~/.Xresources

xrandr --dpi 110

# fonts
xset +fp ~/.fonts
xset fp rehash

# standby
xset dpms 900 900 900
xset +dpms

#xset m 1/3 4
xinput --set-prop 12 'libinput Accel Profile Enabled' 0, 1

SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
export SSH_AUTH_SOCK

exec bspwm

# not need on systemd?
#exec dbus-launch --exit-with-session bspwm
