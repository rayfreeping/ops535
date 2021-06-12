#!/bin/bash
#  OPS535 Lab 6 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 04 Nov, '18
#  Updated on 20 Mar, '21 by Raymond Chan for Lab 8
#  This script runs a series of commands to show the current configuration of th
#  e machine it is run on
#  Run it on VM1, and attach the output to the lab submission.

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back 
on, and do not turn it off again." >&2
	exit 2
fi

#Ensure the host name has been set correctly
date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo

domainname=`hostname -d`

echo INTERFACES
cat /etc/sysconfig/network-scripts/ifcfg-*
echo

echo "Firewall configuration"
for zone in `firewall-cmd --get-active-zones | sed -r '/^[[:space:]]+/ d'`
do
	firewall-cmd --zone=$zone --list-all
done

filesystem=`df | grep centos-root | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo

echo "named:"`systemctl is-active named.service`
echo "named:"`systemctl is-enabled named.service`
echo

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

echo keys
ls -l /etc/named/$domainname-keys
echo
for each in `ls /etc/named/$domainname-keys`
do
	echo $each
	cat /etc/named/$domainname-keys/$each
	echo
done

echo "DNSSec records"
dig AXFR @127.0.0.1 $domainname
