#!/bin/sh
# Script for donwload images from wallhaven.cc to local and remote fs

LOCAL="~/Pictures/Wallpapers/bspwm"
REMOTE="~/pictures/wallpapers"
URL=$(xclip -selection clipboard -o)
URLREGEX="^https?:[-a-zA-Z0-9_./]+(jpe?g|png)$"
WGETOPTIONS="-q --show-progress --progress=bar:force:noscroll"

if [[ -f "${LOCAL}/$(basename ${URL})" ]];
then
    echo "Image already exists. Nothing to do."
    exit 0
fi

if [[ "${URL}" =~ ${URLREGEX} ]];
then
    echo "Fetching to local"
    wget ${WGETOPTIONS} ${URL} -P ${LOCAL}
    echo "Fetching to remote"
    ssh -t fedotov_sv@seamus.core "wget ${WGETOPTIONS} ${URL} -P ${REMOTE}"
else
    echo "Clipboard does not contain valid image URL."
    exit 1
fi
