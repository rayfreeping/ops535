#!/bin/bash
#  OPS535 Lab 5 configuration check
#  Written by: Raymond Chan
#  Created on: 2021.03.09
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on VM2, and attach the output to the lab submission.

rpms="tree nmap-ncat mailx postfix"
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
echo "OPS535 Lab 5 Check Lab Information"
date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo

domainname=`hostname -d`

echo "OPS535 Lab 5 INTERFACES"
cat /etc/sysconfig/network-scripts/ifcfg-*
echo

echo "OPS535 Lab 5 Network Configuration"
ip addr show
echo 

echo "OPS535 Lab 5 Firewall configuration"
for zone in `firewall-cmd --get-active-zones | sed -r '/^[[:space:]]+/ d'`
do
	firewall-cmd --zone=$zone --list-all
done

filesystem=`df | grep /$ | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo

echo "OPS535 Lab 5 Postfix Service Status"
echo "postfix:"`systemctl is-active postfix.service`
echo "postfix:"`systemctl is-enabled postfix.service`
echo

echo "OPS535 Lab 5 Posftfix main.cf"
cat /etc/postfix/main.cf

echo 
 
echo "OPS535 Lab 5 Postfix aliases"
cat /etc/aliases
echo

echo "OPS535 Lab 5 Postfix mail to files"
echo "mail 2 file directory"
tree /tmp
echo

echo "mail 2 file contents"
mail2file=$(find /tmp -name ops535.mail)
cat $mail2file
echo

echo "OPS535 Lab 5 Active Network Ports"
ss -ant
echo 

echo "OPS535 Lab 5 End of Check List"
date

