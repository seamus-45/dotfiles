#!/bin/bash
DOFFSET=$(( $(bspc query -D | wc -l) / 2 ))
N=3
i=1
while [[ $i -le $N ]];
do
  bspc desktop -f \^$i; 
  bspc desktop -f \^$(( $i+$DOFFSET )); 
  sleep 0.5;
  scrot -m $TMPDIR/${i}.png;
  IN="$IN $TMPDIR/${i}.png"
  i=$(( $i + 1 ))
done
convert -append $IN scrot.png
rm -v $IN
