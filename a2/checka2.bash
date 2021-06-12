#!/bin/bash
#  OPS535 Assignment 2 configuration check
#  Written by: Peter Callaghan
#  Last Modified: Apr 12, '21
#  Updated by: Raymond Chan
#  This script runs a series of commands to show the current configuration of the VM it is running on
#  Run it on your VM1, VM2, VM3, and VM4, and attach the output of each to your submission.

if [ `getenforce` != "Enforcing" ]
then
 	echo "SELinux is not currently enforcing on this VM. Turn it back 
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

echo "Resolver Config"
cat /etc/resolv.conf
echo 

echo "Network Address Config"
ip addr show
echo

echo "Kernel Routing table"
ip route
echo 

domainname=`hostname -d`
filesystem=`df | grep cl-root | cut -d' ' -f1`
vmid=UUID:`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`

echo $domainname $vmid

if [ `hostname -s` != "router" ]
then
   echo "Firewalld Config"
   echo "firewalld:"`systemctl is-active firewalld`
   echo "firewalld:"`systemctl is-enabled firewalld`
   echo
   for zone in `firewall-cmd --get-active-zones | sed -r '/^[[:space:]]+/ d'`
   do
	firewall-cmd --zone=$zone --list-all
	echo
   done
   echo
   firewall-cmd --direct --get-all-rules
   echo
   echo Named Config
   echo "named:"`systemctl is-active named.service`
   echo "named:"`systemctl is-enabled named.service`
   echo
   cat /etc/named.conf
   echo
   echo "Zone config"
   for file in `ls /var/named | grep -vE "(named|data|dynamic|slaves|*.jnl|dns-packet|tmp*|*.signed|*.jbk)"`
   do
   	echo "/var/named/$file"
   	cat /var/named/$file
   	echo
   done
   echo
else
   echo "Iptables Config"
   echo "iptables:"`systemctl is-active iptables.service`
   echo "iptables:"`systemctl is-enabled iptables.service`
   echo
   echo "Forward Chain Config"
   iptables -L FORWARD -n -v
   echo "Iptables ALL"
   iptables-save -c
fi

if [ `hostname -s` == "pri-dns"  ]
then
	echo "Zone Data"
	dig AXFR `hostname -d` @127.0.0.1
	echo
elif [ `hostname -s` == "co-nfs" ]
then
	echo "DNSSec trust anchor"
	dig +dnssec +tcp @127.0.0.1 `hostname -d`
	echo
elif [ `hostname -s` == "rns-ldap" ]
then
	echo "DNSSec root zone"
	dig AXFR .  @127.0.0.1
	echo	
fi

ls -ldZ /var/named
echo
ls -lZ /var/named
echo
echo "SEBool"
getsebool named_write_master_zones
echo
echo "INCLUDED FILES"
for file in `grep include /etc/named.conf | cut -d'"' -f2`
do
	echo $file
	cat $file
	echo
done
echo

if [ `hostname -s` == "pri-dns" ]
then
   #postfix configuration parameters
   echo "Postfix parameters"
   postconf
   echo

   #postfix status
   echo "postfix:"`systemctl is-active postfix.service`
   echo "postfix:"`systemctl is-enabled postfix.service`
   echo

   #logs
   echo "mail log"
   (cat /var/log/maillog-* 2> /dev/null; cat /var/log/maillog) | grep postfix
   echo
fi

hostnamectl
echo $domainname $vmid
date
