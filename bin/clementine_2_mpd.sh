#!/bin/bash
# dirty script
# copy ratings from clementine database to mpd sticker database.
DB=~/.config/Clementine/clementine.db
alias urldecode=''
sqlite3 ${DB} "select filename,rating from songs where rating!=-1;" |\
  xargs -0 -L 1 python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])" |\
  while read line;
  do
    ff=$(echo ${line} | awk -F'|' '{print $1}' | sed 's;file:///home/fedotov_sv/music/;;')
    rr=$(echo ${line} | awk -F'|' '{print $2}' | sed 's/0.//g')
    echo ${rr} ::: ${ff}
    mpc sticker "${ff}" set rating ${rr}
  done

