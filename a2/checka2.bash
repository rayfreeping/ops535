#!/bin/bash
#  OPS535 Assignment 2 configuration check
#  Written by: Peter Callaghan
#  Last Modified: 12 Apr. '21
#  Updated by: Raymond Chan
#  This script runs a series of commands to show the current configuration of the VM it is run on
#  Run it on your VM1, VM2, VM3, and VM4, and attach the output of each to your submission.

echo "firewalld:"`systemctl is-active firewalld`
echo "firewalld:"`systemctl is-enabled firewalld`
echo "named:"`systemctl is-active named.service`
echo "named:"`systemctl is-enabled named.service`
echo
for zone in `firewall-cmd --get-active-zones | sed -r '/^[[:space:]]+/ d'`
do
	firewall-cmd --zone=$zone --list-all
	echo
done
echo
firewall-cmd --direct --get-all-rules
echo

if [ `hostname -s` != "router" ]
then
   echo Named Config
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
	echo "DNSSec secured recursion"
	dig +dnssec +tcp @127.0.0.1 isc.org.
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

