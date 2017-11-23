#!/bin/bash
RC="$HOME"/.config/nvim/pager.vim

if [[ $# -lt 1 ]];
then
  nvimpager -u "$RC" -c AnsiEsc -
else
  if [[ -r $1 ]];
  then
    nvimpager -u "$RC" "$1"
  else
    sudo cat "$1" | nvimpager -u "$RC" -
  fi
fi
