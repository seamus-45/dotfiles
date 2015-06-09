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
    mplayer -geometry 500x300-50-50 -really-quiet -prefer-ipv4 $(quvi dump -p rfc2483 "${URI}" | grep -v \#) &
    # -ontop
    #until WID=$(wmctrl -l | grep MPlayer); do sleep 1; done
    #echo "Found mplayer window $(echo $WID | awk '{print $1}'). Make it sticky."
    #wmctrl -r mplayer -b add,sticky
  done
else
    mplayer -geometry 500x300-50-50 -really-quiet -prefer-ipv4 $(quvi dump -p rfc2483 "${1}" | grep -v \#) &
    # -ontop
    #until WID=$(wmctrl -l | grep MPlayer); do sleep 1; done
    #echo "Found mplayer window $(echo $WID | awk '{print $1}'). Make it sticky."
    #wmctrl -r mplayer -b add,sticky
fi
