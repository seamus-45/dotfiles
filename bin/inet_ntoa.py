#!/bin/env python2

import socket
import struct
import sys

nbo = int(sys.argv[1])
hbo = socket.ntohl(nbo)
addr = socket.inet_ntoa(struct.pack('!L',hbo))
print addr
