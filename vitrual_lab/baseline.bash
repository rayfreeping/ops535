#!/usr/bin/env bash
# Date: 2021.02.02
# Collect Base Line information on a VM
#
# network configuration
echo "Network Device and IP address"
ip a
echo "Network Routing Information"
ip route
echo "Disk Usage"
df -v
echo "Mounted file systems"
mount
echo "Kernel Version"
uname -a
