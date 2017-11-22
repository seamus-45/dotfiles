#!/bin/bash
if [[ -n $TMUX ]];
then
    W=$(tmux display -p '#{pane_width}')
    H=$(tmux display -p '#{pane_height}')
fi

~/.config/ranger/scope.sh "$1" "${W-80}" "${H-24}"
