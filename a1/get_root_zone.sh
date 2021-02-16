#!/bin/bash
# Created by: Raymond Chan
# for OPS535
# (c) 2016 - update for new wiki site
# (c) 2017 - update to prompt user to set the followings
#	     fqdn,ip for root name server
#	     email for dns admin
#	RNS_FQDN, RNS_IP, DNS_ADMIN_EMAIL
# (c) 2020 - update for the new wiki url
#
if [ -z "${RNS_FQDN}" ]
then
	echo "Please set the shell variable RNS_FQDN to the FQDN of your" >&2
	echo "root name server and run this script again." >&2
	exit 1
fi

if [ -z "${RNS_IP}" ]
then
	echo "Please set the shell variable RNS_IP to the IP address" >&2
        echo "of your root name server and run this script again." >&2
	exit 2
fi

if [ -z "${DNS_ADMIN_EMAIL}" ]
then
	echo "Please set the shell variable DNS_ADMIN_EMAIL to the" >&2
	echo "email address of your DNS administrator and run this" >&2
        echo "script again." >&2
	exit 3
fi
# start loading dns information from the web
url=https://wiki.cdot.senecacollege.ca/w/index.php/Domainreg

if [ ! -f raw.txt ]
then
	echo "Gettting wiki file from the web ..." >&2
	wget -O raw.txt $url
fi

buffer=$(cat raw.txt| grep ^'<td>')

nl=$(echo "$buffer"|wc -l)
a=0
b=6
# generating the zone file header
SN=$(date +%y%j%H) # yydddHH
echo "\$TTL 3600"
echo "@ IN SOA ${RNS_FQDN} ${DNS_ADMIN_EMAIL} (${SN} 1h 15m 30d 1h)"
echo "      IN NS ${RNS_FQDN}"
echo "${RNS_FQDN} IN A ${RNS_IP}"

while [ $a -lt $nl ]
do
	stuff=$(echo "$buffer"| head -"$b" | tail -5|nl|sed -e "s/<td>/x/g")
	#  echo "$stuff"
	fields=$(echo "$stuff"|sed -e "s/ //g"|awk -Fx {'print $2'})

	parameters=$(echo $fields)
	cc=$(echo $parameters | wc -w)
        # echo "paratest cc is $cc"

	if [ "$cc" -gt 0 ]
	then	
		#echo $a $parameters
		#read yyy	
		set $parameters
		if [ "$1" != "domainname" ]
		then
			if [ "$1" != "" -a "$3" != "" -a "$4" != "" ]
			then

	 			echo -e "${1}. \tIN \tNS \t$4."
	 			echo -e "${4}. \tIN \tA \t$3"
				echo " "
	
			fi
		fi
	fi

	let a=a+6
	let b=b+6

	#read xxx
done
