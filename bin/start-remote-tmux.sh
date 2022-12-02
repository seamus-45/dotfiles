#!/usr/bin/bash
[ -d /sys/class/net/vpn0 ] && alacritty --class=remote-L -e ssh -t -- fedotov_sv@seamus.core tmux attach-session -t remote-L || alacritty --class=remote-L &
[ -d /sys/class/net/vpn0 ] && alacritty --class=remote-R -e ssh -t -- fedotov_sv@seamus.core tmux attach-session -t remote-R || alacritty --class=remote-R &
sleep 1s
xdotool search --class remote-L windowunmap
xdotool search --class remote-R windowunmap
