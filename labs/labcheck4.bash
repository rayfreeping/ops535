#!/bin/bash
#  OPS535 Lab 4 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 01 Feb, '19
#  Modified by Raymond Chan on 2021.02.16
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on VM1, and attach the output to the lab submission.

if [ ! -f "/root/dns-packet" ]
then
        echo "tcpdump file /root/dns-packet doesn't exist. Please review Investigation 1 and try again." >&2
        exit 3
fi

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
fi

if [ ! -f "/root/dns-packet" ]
then
        echo "tcpdump file /root/dns-packet doesn't exist. Please review Investigation 1 and try again." >&2
        exit 3
fi

#Ensure the host name has been set correctly
date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo

echo INTERFACES
cat /etc/sysconfig/network-scripts/ifcfg-*
echo

echo "Firewall configuration"
for zone in `firewall-cmd --get-active-zones | sed -r '/^[[:space:]]+/ d'`
do
	firewall-cmd --zone=$zone --list-all
done

filesystem=`df | grep root | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo

echo "named:"`systemctl is-active named.service`
echo "named:"`systemctl is-enabled named.service`

echo "DNS config"
ls -ldZ /var/named
echo
ls -lZ /var/named
echo
echo "SEBool"
getsebool named_write_master_zones
echo
echo named config
cat /etc/named.conf
echo

echo "Zone config"
for file in `ls /var/named | grep -vE "(named|data|dynamic|slaves|*.jnl|dns-packet)"`
do
	echo "/var/named/$file"
	cat /var/named/$file
	echo
done


echo "Journals"
for file in `ls /var/named | grep -E "*.jnl"`
do
	echo "/var/named/$file"
	named-journalprint /var/named/$file
	echo
done

#TODO:  replace $dumpfile with the absolute path to the tcpdump file you created in investigation 1
echo "dns packets"
tcpdump -r /root/dns-packet
echo "end dns packets"
echo
