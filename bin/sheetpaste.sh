#!/bin/bash
TEMP=$(mktemp)

tee -a >${TEMP}

if [ -s ${TEMP} ]; then
  curl -s -i -X POST --data-urlencode content@${TEMP} --data-urlencode age='+3 month' http://localhost/api/post | tail -n1
else
  echo "Paste is empty!"
  exit 1
fi

rm -f ${TEMP}
