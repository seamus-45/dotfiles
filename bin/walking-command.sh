#!/bin/bash
usage() {
    echo "Usage: $0 [-w <timeout>] -n <network> [-f <from>] -[t <to>] -c <command>"
    echo "E.g. $0 -n 10.1.1.0 -f 10 -t 20 -c uptime"
}

validate_net() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        read -a ip <<< $ip
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -eq 0 ]]
        stat=$?
    fi
    if [ "$stat" -ne 0 ]; then
        echo "Invalid network address."
        exit 1
    fi
}

OPTIND=1
while getopts "hvn:f:t:w:c:" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        v)
            v=1
            ;;
        n)
            net=$OPTARG
            ;;
        f)
            from=$OPTARG
            ;;
        t)
            to=$OPTARG
            ;;
        w)
            w=$OPTARG
            ;;
        c)
            cmd=$OPTARG
            ;;
        *)
            usage
            exit 1
        esac
done

# check arguments
if [[ -z "$net" || -z "$cmd" ]]; then
    usage
    exit 1
else
    validate_net "$net"
fi

# set defaults
[ -n "$from" ] || from=2
[ -n "$to" ] || to=254
[ -n "$w" ] || w=3

echo -e "Walking over list...\n"
for host in $(seq "$from" "$to"); do
    addr="${net%.*}.${host}"
    [ $v -eq 1 ] && echo "Connecting to ${addr}:"
    ssh -q -o ConnectTimeout="$w" root@"$addr" "$cmd" || echo "${addr}: timeout";
done

exit 0
