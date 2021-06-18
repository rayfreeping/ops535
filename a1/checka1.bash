#!/bin/bash
#  OPS535 Assignment 1 configuration check
#  Written by: Peter Callaghan
#  Updated on June 18, 2021 by Raymond Chan
#  This script runs a series of commands to show the current configuration of the machine it is run on
#  Run it on pri-dns, co-nfs, and rns-ldap, and attach the output to the assignment submission.
date
echo
echo "hostname:"`hostname`
echo
echo "SELinux status:"`getenforce`
echo
echo release:`uname -r`
echo
filesystem=`df | grep centos-root | cut -d' ' -f1`
echo "UUID:"`blkid $filesystem | sed -r 's/^.*UUID="([-a-zA-Z0-9]+)".*$/\1/'`
echo
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

echo "Addresses"
ip address show
echo
echo Named Config
cat /etc/named.conf
echo
echo "Zone config"
for file in `ls /var/named | grep -vE "(named|data|dynamic|slaves|*.jnl|tmp*)"`
do
	echo "/var/named/$file"
	cat /var/named/$file
	echo
done

case `hostname -s` in
	pri-dns)
		echo "DNS config"
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
		echo "AUTHENTICATION PROFILE"
		echo "active profile: "`authselect current`
		echo

		echo "AUTHENTICATION ISSUES"
		sssctl config-check
		echo

		echo "AUTHENTICATION SETTINGS"
		cat /etc/sssd/sssd.conf
		echo
		echo "NFS Mounts"
		mount | grep nfs
		echo
		;;
	co-nfs)
		echo "AUTHENTICATION PROFILE"
		echo "active profile: "`authselect current`
		echo

		echo "AUTHENTICATION ISSUES"
		sssctl config-check
		echo

		echo "AUTHENTICATION SETTINGS"
		cat /etc/sssd/sssd.conf
		echo

		echo "nfs-server:"`systemctl is-active nfs-server`
		echo "nfs-server:"`systemctl is-enabled nfs-server`
		echo
		echo "EXPORTS - FILE"
		cat /etc/exports
		echo
		echo "EXPORTS - ACTIVE"
		exportfs
		echo
		;;
	rns-ldap)
		echo "slapd:"`systemctl is-active slapd.service`
		echo "slapd:"`systemctl is-enabled slapd.service`
		echo
		echo "BASE CONFIG"
		cat /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}mdb.ldif
		basedn=`grep olcSuffix /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}mdb.ldif | cut -d' ' -f2`
		echo
		echo "CERTIFICATES"
		slapcat -b "cn=config" | egrep "Certificate(Key)?File"
		echo
		echo "OPENLDAP CONFIG"
		cat /etc/openldap/ldap.conf
		echo
		echo "CONTENTS"
		ldapsearch -x -b "$basedn" '(objectClass=*)'
		echo

		echo "NFS Mounts"
		mount | grep nfs
		echo
		;;
esac
