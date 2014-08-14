#!/bin/bash
if [[ $# -ne 1 ]]; then
  echo 'Please specify iso file for unpack.'
  exit 1
fi
if [[ -f "$1" ]]; then
  [[ -d image ]] && rm -rf image || mkdir -pv image
  [[ ! -d iso ]] && mkdir -v iso
  mount -v -o loop "$1" iso
  echo -n 'Extract iso to image dir... '
  cp -a iso/* image/ && echo 'done'
  umount -v iso
  rm -rfv iso
fi
