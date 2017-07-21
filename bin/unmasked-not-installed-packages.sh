#!/bin/bash
find /etc/portage/package.* -type f -exec cat {} \; | sed 's/[<=>]//g' | awk '{print $1}' | awk -F'/' '{print $2}' | sed -r 's/(.*)-[0-9].*/\1/' | while read ff; do if ! `eix -I $ff >/dev/null`; then echo -e "$ff"; fi ; done
# for quick remove
# | while read ff; do grep -r ${ff} | awk -F':' '{print $1}' | xargs -0 echo | grep -v \^\$ | xargs sed -i "/${ff}/d"; done
