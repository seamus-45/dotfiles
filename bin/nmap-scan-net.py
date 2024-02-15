#!/usr/bin/env python3

from os.path import isfile
from os import getuid
import argparse
import json
import socket
import subprocess

NMAP = '/usr/bin/nmap'


def parse_args():
    p = argparse.ArgumentParser(description='Network scanner',
                                formatter_class=argparse.RawTextHelpFormatter)
    p.add_argument('-i', '--icmp', action='store_true',
                   help='Make traditional ICMP echo scan (needs privileges)')
    p.add_argument('-t', '--time', action='store_true',
                   help='Add time to the output')
    p.add_argument('-o', '--output', default='default',
                   choices=['fabric', 'json', 'default', 'netbox'],
                   help='Output format: fabric, json, default, netbox')
    p.add_argument('-d', '--debug', action='store_true',
                   help='Print raw text for debug')
    p.add_argument('-a', '--all', action='store_true',
                   help='Also print down hosts')
    p.add_argument('subnet', type=str,
                   help='Network subnet (for example 10.1.1.0/24)')
    p.set_defaults(func=print_output)
    return p.parse_args()


def filter_str(s):
    for i in "()":
        s = s.replace(i, "")
    return s


def print_output(args):
    output = get_output(args)

    if args.time:
        print(output.split('\n')[0])

    if args.output == 'json':
        result = {}
        for line in output.split('\n'):
            if line.startswith('Host'):
                _line = line.split()
                result[_line[1]] = {}
                result[_line[1]]['hostname'] = filter_str(_line[2])
                result[_line[1]]['status'] = _line[4]
        print(json.dumps(result, indent=4))

    elif args.output == 'fabric':
        result = []
        for line in output.split('\n'):
            if line.startswith('Host'):
                _line = line.split()
                result.append(_line[1])
        print(','.join(result))

    elif args.output == 'netbox':
        status_map = {
            'Up': 'active'
        }
        print('; REPLACE "UNKNOWN" PLACEHOLDER WITH ACTUAL DATA')
        print('address,dns_name,status')
        for line in output.split('\n'):
            if line.startswith('Host'):
                _, ip, hostname, _, status = line.split()
                netbox_status = status_map.get(status, 'UNKNOWN')
                netbox_hostname = filter_str(hostname) or 'UNKNOWN'
                netbox_subnet = args.subnet.split('/')[1]

                print(f'{ip}/{netbox_subnet},{netbox_hostname},{netbox_status}')

    else:
        for line in output.split('\n'):
            if line.startswith('Host'):
                _, ip, hostname, _, status = line.split()
                # try to resolve PTR record for down host
                if status == "Down":
                    try:
                        ptr = socket.gethostbyaddr(ip)
                        hostname = ptr[0]
                    except socket.herror:
                        pass
                if ip.endswith(".200") and not filter_str(hostname):
                    hostname = "TEMPLATE"
                print(f'{ip:<16} {status:<6} {filter_str(hostname):<16}')


def get_output(args):
    tcpsyn = '-PS22'
    icmp = '-PE'
    scantype = icmp if args.icmp else tcpsyn
    cmd = f'{NMAP} -sP {scantype} {args.subnet} -oG -'
    if args.all:
        cmd = cmd + ' -v'
    if args.icmp and (getuid() != 0):
        print('You cannot perform ICMP scan unless you are root')
        exit(4)
    # print(f'INFO: run cmd "{cmd}"')
    try:
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
    except:
        print('Error in running {0}'.format(NMAP))
        exit(3)

    if args.debug:
        print('DEBUG: raw output after regex and sorting')
        print(output)
    return output.decode('utf-8')


if __name__ == "__main__":
    if isfile(NMAP):
        args = parse_args()
        args.func(args)
    else:
        print('{0} not found. First install nmap.'.format(NMAP))
        exit(2)
