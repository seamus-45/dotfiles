#!/bin/bash
# ssh-multi for tmux
# https://gist.github.com/dmytro/3984680
# adapted by seamus
read target
if [[ -n ${target} ]];
then
  pool=( `nmap -p 22 ${target}/24 | grep open -B3 | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'` )
  if [[ ${#pool[@]} -gt 1 ]];
  then
    # skip gateway
    [[ ${pool[0]} =~ \.1$ ]] && unset pool[0]
    # open new window in tmux with target name
    tmux new-window -n "${target}" "ssh support@${pool[1]} -YC"
    unset pool[1]
    # and split others
    if [[ ${#pool[@]} -gt 0 ]];
    then
      for host in ${pool[@]}; do
        tmux split-window -h "ssh support@${host} -YC"
      done
      tmux select-layout tiled > /dev/null
      tmux select-pane -t 0
      tmux set-window-option synchronize-panes on > /dev/null
    fi
  fi
fi
