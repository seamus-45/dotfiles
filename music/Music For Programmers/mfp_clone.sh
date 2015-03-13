wget -O - musicforprogramming.net/rss.php 2>/dev/null | grep enclosure | awk '{print $2}' | sed 's@^url="\(.*\)"$@\1@g' | while read ff; do wget -c --limit-rate=500k $ff; done
