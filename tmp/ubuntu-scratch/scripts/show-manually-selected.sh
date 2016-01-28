#!/bin/bash
chroot chroot aptitude search '~i !~M' -F '%p' --disable-columns | sort -u
