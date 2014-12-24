#!/bin/sh
yellow='\e[1;33m'
nc='\e[0m'
ps="${yellow}>${nc}"

if [ ! -x /usr/bin/quvi ]; then
  echo 'You must install quvi for parse URI media content.'
  exit 1
fi

if [ $# -lt 1 ]; then
  echo 'Paste URL here and press <enter> to play.'
  echo 'Leave blank and press <enter> to quit.'
  while echo -ne ${ps}; read URI; do
    [[ -z ${URI} ]] && exit 0
    mplayer -geometry 500x300+2850+680 -ontop -really-quiet -prefer-ipv4 $(quvi dump -p rfc2483 "${URI}" | grep -v \#)
  done
else
    mplayer -geometry 500x300+2850+680 -ontop -really-quiet -prefer-ipv4 $(quvi dump -p rfc2483 "${1}" | grep -v \#)
fi
