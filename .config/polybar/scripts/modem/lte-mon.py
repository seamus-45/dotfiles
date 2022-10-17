#!/usr/bin/env python
# -*- coding: utf-8 -*- # PEP 263

import pprint
from huawei_lte_api.Client import Client
from huawei_lte_api.Connection import Connection


def scale_units(rate):
    decimal_places = 2
    for unit in ['bps', 'Kbps', 'Mbps', 'Gbps', 'Tbps']:
        if rate < 1000.0:
            if unit == 'bps':
                decimal_places = 0
            break
        rate /= 1000.0
    return f"{rate:.{decimal_places}f}{unit}"


with Connection('http://admin:k4A3Fodk@192.168.8.1/') as connection:
    client = Client(connection)  # This just simplifies access to separate API groups, you can use device = Device(connection) if you want

    signal = client.device.signal()
    traffic = client.monitoring.traffic_statistics()
    sms = client.sms.sms_count()
    status = client.monitoring.status()

    result = u":{power} SINR:{sinr} {sms_icon}:{sms_count} {down} {up}".format(
        power = status['SignalIcon'],
        sinr = signal['sinr'],
        sms_icon = '' if int(sms['LocalUnread']) else '',
        sms_count = int(sms['LocalUnread']),
        down = scale_units(int(traffic['CurrentDownloadRate']) * 8),
        up = scale_units(int(traffic['CurrentUploadRate']) * 8),
    )

    print(result)
    pp = pprint.PrettyPrinter(indent=4)
