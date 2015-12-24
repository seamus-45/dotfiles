#!/bin/bash

# messaging functions
c_red="\e[31m"
c_green="\e[32m"
c_def="\e[39m"

ebegin() {
	last_emsg="$*"
	echo -n " * $last_emsg: "
}

eend() {
	if [ "$1" = 0 ] || [ $# -lt 1 ] ; then
		echo -e "${c_green}done${c_def}"
	else
		shift
		echo -e "${c_red}failed${c_def} $*"
		exit 1
	fi
}

mountfs() {
	mountpoint $1 >/dev/null
	if [[ $? -ne 0 ]];
	then
		ebegin "mounting $1"
		mount -o rbind /${1#*/} $1
		eend $?
	else
		ebegin "filesystem $1 is already mounted"
		eend 0
	fi
}
