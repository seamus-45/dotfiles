#!/home/seamus/.config/polybar/scripts/ros/venv/bin/python
# -*- coding: utf-8 -*- # PEP 263
# https://github.com/LaiArturs/RouterOS_API

import ros
import ros_api
import socket
import sys


def scale_units(rate):
    # input: integer
    decimal_places = 2
    for unit in ['bps', 'Kbps', 'Mbps', 'Gbps', 'Tbps']:
        if rate < 1000.0:
            if unit == 'bps':
                decimal_places = 0
            break
        rate /= 1000.0
    return f"{rate:.{decimal_places}f}{unit}"


def check_connection():
    try:
        socket.create_connection((ros.host, ros.port))
        return True
    except (OSError, TimeoutError):
        print('connection error')
        return False


if __name__ == '__main__':
    # check connection
    if not check_connection():
        sys.exit(1)
    # setup session and authenticate
    router = ros_api.Api(ros.host, user=ros.username, port=ros.port)

    # get lte modem stats
    r = router.talk('/interface/lte/info\n=number=0\n=once')[0]
    name = r['current-operator']
    # cqi lvl - 0..15 (quality)
    # 100/15 = 6.66
    lvl = round(int(r['cqi']) * 6.66)
    rssi = r['rssi']
    rsrp = r['rsrp']
    sinr = r['sinr']
    result = f"{name}  {lvl}% RSSI {rssi}дБм RSRP {rsrp}дБм SINR {sinr}дБ"

    # get traffic stats
    r = router.talk('/interface/monitor-traffic\n=interface=lte\n=once')[0]
    rxb = scale_units(int(r['rx-bits-per-second']))
    txb = scale_units(int(r['tx-bits-per-second']))
    result = result + f" {rxb} {txb}"

    print(result)
