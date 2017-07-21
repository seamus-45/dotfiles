#!/bin/bash
for i in /var/db/pkg/*/*; do if ! egrep ^gentoo$ $i/repository >/dev/null; then echo -e "`cat $i/repository`\t`basename $i`"; fi; done | sort
