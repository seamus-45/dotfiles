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
	fi
}
