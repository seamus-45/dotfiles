#!/bin/bash

usage() {
    local SELF=$(basename $0)
    echo -e "Find YAML files under PATH and print lines between PATTERN and next blank line\n"
    echo -e "Usage: $SELF [-H] PATTERN PATH\n"
    echo "Options:"
    echo -e "\t-H\tPrint the file name for each match"
}

OPTIND=1
while getopts "hH" opt; do
    case "$opt" in
        h) usage ; exit 0 ;;
        H) NAMES=true ;;
        *) usage ; exit 1 ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

if [ $# -lt 2 ];
then
    usage
    exit 1
fi

if [ "$NAMES" = true ];
then
    find $2 -regex '.*\.ya?ml' -exec grep --color=always -l $1 {} \; -exec sed -n "/$1/,/^$/p" {} \;
else
    find $2 -regex '.*\.ya?ml' -exec sed -n "/$1/,/^$/p" {} \;
fi
