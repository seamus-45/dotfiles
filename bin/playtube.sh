#!/bin/sh
yellow='\e[1;33m'
nc='\e[0m'
ps="${yellow}>${nc}"

if [ ! -x /usr/bin/youtube-dl ]; then
  echo 'You must install youtube-dl for parse URI media content.'
  exit 1
fi

if [ $# -lt 1 ]; then
  echo 'Paste URL here and press <enter> to play.'
  echo 'Leave blank and press <enter> to quit.'
  while echo -ne ${ps}; read URI; do
    [[ -z ${URI} ]] && exit 0
    mpv -geometry 500x300-50-60 -really-quiet $(youtube-dl --get-url "${URI}") &
  done
else
    mpv -geometry 500x300-50-60 -really-quiet $(youtube-dl --get-url "${1}") &
fi
