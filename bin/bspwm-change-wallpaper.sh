#!/bin/bash
# Change current wallpaper for my bspwm

ITEMS=("$HOME"/pictures/wallpapers/*)
LEN=${#ITEMS[@]}
CURRENT=$(cat "$HOME"/.config/bspwm/wallpaper)

function next {
    for (( i=0; i<LEN; i++ )); do
        [ "$CURRENT" != "${ITEMS[$i]}" ] && continue ||:
        if [ "$i" -eq $(( LEN - 1 )) ];
        then
            echo "${ITEMS[0]}" > "$HOME"/.config/bspwm/wallpaper
            hsetroot -fill "${ITEMS[0]}"
            echo "${ITEMS[0]}"
            break
        else
            echo "${ITEMS[$i+1]}" > "$HOME"/.config/bspwm/wallpaper
            hsetroot -fill "${ITEMS[$i+1]}"
            echo "${ITEMS[$i+1]}"
        fi
    done
}

function prev {
    for (( i=$(( LEN - 1 )); i>=0; i-- )); do
        echo $i
        [ "$CURRENT" != "${ITEMS[$i]}" ] && continue ||:
        if [ "$i" -eq 0 ];
        then
            echo "${ITEMS[$(( LEN - 1 ))]}" > "$HOME"/.config/bspwm/wallpaper
            hsetroot -fill "${ITEMS[$(( LEN - 1 ))]}"
            echo "${ITEMS[$(( LEN - 1 ))]}"
            break
        else
            echo "${ITEMS[$i-1]}" > "$HOME"/.config/bspwm/wallpaper
            hsetroot -fill "${ITEMS[$i-1]}"
            echo "${ITEMS[$i-1]}"
        fi
    done
}

function random {
    RND=$(( RANDOM % LEN ))
    echo "${ITEMS[$RND]}" > "$HOME"/.config/bspwm/wallpaper
    hsetroot -fill "${ITEMS[$RND]}"
    echo "${ITEMS[$RND]}"
}

if [ ! "$LEN" -ge 1 ]; then
    echo 'Put wallpapers into ' "$HOME"
    exit 1
fi

if [ -z "$CURRENT" ];
then
    random
    CURRENT=$(cat "$HOME"/.config/bspwm/wallpaper)
fi

if [ $# -lt 1 ];
then
    next
else
    case "$1" in
        next)
            next
            ;;
        prev)
            prev
            ;;
        random)
            random
            ;;
        *)
            echo "Usage: $(basename $0) [next|prev|random]"
            exit 1
            ;;
    esac
fi
