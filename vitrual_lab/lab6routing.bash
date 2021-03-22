#! /bin/bash
if [ -z "$MY_VLS_NO" ]
then
	echo "Please run the following command to assign your network number" >&2
	echo "to the shell varible MY_VLS_NO and run this script again." >&2
	echo "Please replace xx with your actual network number." >&2
	echo "  export MY_VLS_NO=xx" >&2
	exit 1
fi
X=${MY_VLS_NO}
echo "Your Network Number is $X"

#change the following variable if necessary
OTHER_VLS_NOS=$(seq 1 43)

Y=`echo ${OTHER_VLS_NOS}`
echo "Route to be added for the network number(s) $Y"
echo -n "Press ENTER to continue ... "
read dummy

# Add new route
for y in $Y
do
	if [ "$X" -ne "$y" ]
	then
	    nmcli con modify ens192 +ipv4.routes "192.168.${y}.0/24 172.20.${y}.1 100"
	    echo "Adding route to 192.168.${y}.0 network." 
	fi
done
nmcli con down ens192
nmcli con up ens192
ip route show
 
# enable IP forwarding on the gateway, add "net.ipv4.ip_forward = 1" to /etc/sysctl.conf 
echo "1" > /proc/sys/net/ipv4/ip_forward
