#!/bin/bash
DOFFSET=6
N=$1
i=1
IN=''
while [[ $i -le $N ]];
do
  bspc desktop -f \^$i; 
  bspc desktop -f \^$(( i+DOFFSET )); 
  sleep 1;
  maim ${i}.png;
  IN="$IN ${i}.png"
  i=$(( i + 1 ))
done
convert -append "$IN" bspwm.png
rm -v "$IN"
