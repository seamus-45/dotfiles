#!/bin/bash
read -r X Y W H G ID < <(slop -f "%x %y %w %h %g %i")
ffmpeg -f x11grab -s "$W"x"$H" -i :0.0+$X,$Y ~/capture.mp4
