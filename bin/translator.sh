#!/bin/sh
# wrapper script for genru.sh
yellow='\e[1;33m'
nc='\e[0m'
ps="${yellow}>"

echo -ne ${ps};
while read ff;
do
  genru.sh -s ${ff};
  echo -ne ${ps};
done
echo -ne ${nc}
