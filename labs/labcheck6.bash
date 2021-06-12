#!/bin/bash
#  OPS535 Lab 6 configuration check
#  Written by: Raymond Chan
#  Created on: 2021.03.22
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on VM1, VM2, VM3, and VM4, capture and name the output as
#  VM1 --> lab6vm1.txt
#  VM2 --> lab6vm2.txt
#  VM3 --> lab6vm3.txt
#  VM4 --> lab6vm4.txt
#  and attach the above files to the lab submission.

# Requirements:
# VM1:   iptables.service
#        ip_forward 1
#        ip address on ens192, ens224
#        ip route (route to 192.168.y.0/24 network)
#            
# VM2-4: firewalld.service
#        ip_forward 0
#        ip address on ens192, ens224
#        ip route (one default route, route to 192.168.0.0/16 network)
#

if [ `getenforce` != "Enforcing" ]
then
	echo "SELinux is not currently enforcing on this machine.  Turn it back on, and do not turn it off again." >&2
	exit 2
fi

#Ensure the host name has been set correctly
echo "OPS535 Lab 6 Check Lab Information"
date
echo "Basic System Info"
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo
echo "IP FORWARD:"`sysctl net.ipv4.ip_forward`
echo 
echo "End Basic System Info"
domainname=`hostname -d`

echo "NET INTERFACES"
cat /etc/sysconfig/network-scripts/ifcfg-*
echo

echo "Lab 6 Network Configuration"
echo "IP ADDRESSES"
ip addr show
echo "END IP ADDRESSES"
echo "IP ROUTES"
ip route
echo "END IP ROUTES"
echo 

echo "Lab 6 Firewall configuration"
echo "firewalld:"`systemctl is-active firewalld.service`
echo "firewalld:"`systemctl is-enabled firewalld.service`
echo "iptables:"`systemctl is-active iptables.service`
echo "iptables:"`systemctl is-enabled iptables.service`

if [ "`systemctl is-active firewalld.service`" = active ]
then
    echo "FIREWALLD configuration"
    for zone in `firewall-cmd --get-active-zones | sed -r '/^[[:space:]]+/ d'`
    do
	firewall-cmd --zone=$zone --list-all
    done
    echo "END FIREWALLD configuration"
fi

if [ "`systemctl is-active iptables.service`" = active ]
then
    echo "IPTABLES Current Configuration"
    iptables -L FORWARD -n -v 
    echo "END IPTABLES Current Configuration"
fi

filesystem=`df | grep /$ | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo

echo "OPS535 Lab 6 End of Check List"
date

