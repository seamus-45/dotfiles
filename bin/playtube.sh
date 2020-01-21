#!/bin/sh
if [ $# -lt 1 ]; then
  echo "Usage: $(basename $0) URL"
  exit 1
fi

URL=$1

if [[ ${URL} =~ ^viewtube ]];
then
  URL=$(echo ${URL} | sed -e "s/viewtube://")
fi

mpv -geometry -11-11 --autofit=500x300 -really-quiet --x11-name 'pip' "${URL}" &
