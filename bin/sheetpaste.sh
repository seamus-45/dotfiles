#!/bin/bash
TEMP=$(mktemp)

while read input; do
  echo $input | tee >${TEMP}
done

if [ -s ${TEMP} ]; then
  curl -s -i -X POST --data-urlencode content@${TEMP} --data-urlencode age='+3 month' http://localhost/api/post | tail -n1
else
  echo "Paste is empty!"
  exit 1
fi
