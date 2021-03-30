#!/bin/bash
#  OPS535 Lab7 configuration check
#  Written by: Raymond Chan
#  Last Modified: 22 Mar, '21
#  This script runs a series of commands to show the current configuration of 
#  the machine it is run on
#  Run it on VM2, and attach the output to the lab submission.
#  Caputre postfix and spf configuration
rpms="tree nmap-ncat mailx postfix bind pypolicyd-spf"
for rpm in $rpms
do
    rpm -q $rpm &>/dev/null
    if [ $? -ne 0 ]
	then
		echo "You must have the $rpm rpm package installed." >&2
		echo "Please install all of the following rpm packages:" >&2
		echo "rpm package: $rpms" >&2
		echo "Do the lab and then run this lab check script again." >&2
		exit 1
        fi
done

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
fi

#Ensure the host name has been set correctly
echo "OPS535 Lab 7 Start of Check List"
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

echo "Network Configuration"
ip addr show
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
echo named config
cat /etc/named.conf
echo
echo "DNS zone files start"

for zfile in `ls /var/named`
do
    zfile_type=`file -b /var/named/$zfile`
    if [ "$zfile_type" = "ASCII text" ]
    then
       echo "zone file: /var/named/$zfile"
       cat  /var/named/$zfile
    fi
done
echo
echo "DNS zone file end"
echo

echo "Postfix Service Status"
echo "postfix:"`systemctl is-active postfix.service`
echo "postfix:"`systemctl is-enabled postfix.service`
echo

echo "Postfix main.cf start"
cat /etc/postfix/main.cf
echo "Postfix main.cf end"
echo 
 
echo "Postfix master.cf start"
cat /etc/postfix/master.cf
echo "Postfix master.cf end"
echo

echo "OPS535 Lab 7 End of Check List"
date
