#!/bin/bash
# ~/.local/bin/tmux-session-manager

FIND_DEFAULT_COMMAND="tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\""

tmux list-sessions | sed -E 's/:.*$//' | grep -v "^$(tmux display-message -p '#S')$"\
    | fzf --reverse --bind "ctrl-x:execute(tmux kill-session -t {})+reload(${FIND_DEFAULT_COMMAND})"\
    --bind "ctrl-n:execute(bash -c 'read -p \"Name: \" name; tmux new -d -s \"\$name\"')+reload(${FIND_DEFAULT_COMMAND})" \
    --bind "ctrl-r:reload(${FIND_DEFAULT_COMMAND})"\
    --header 'Enter: switch session | Ctrl-X: kill session | Ctrl-N: new session | Ctrl-R: refresh list'\
    | xargs tmux switch-client -t
