#!/bin/bash
if [[ $# -lt 1 ]];
then
  nvimpager -u NORC -
else
  nvimpager -u NORC "$1"
fi
