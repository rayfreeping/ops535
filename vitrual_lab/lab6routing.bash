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
if [ -z "$OTHER_VLS_NOS" ]
then
	echo "Please run the following command to assign the list of " >&2
	echo "private VLS Networks you want to add a route on your gateway " >&2
	echo "to the shell variable OTHER_VLS_NOS and run this script again." >&2
	echo "The following command assign 32, 33, 34, 35, 41, 42, and 43" >&2
	echo "to the variable OTHER_VLS_NOS. Please replace those number" >&2
	echo "with the ones you actually wanted." >&2
	echo "  export OTHER_VLS_NOS=\"32 33 34 35 41 42 43\"" >&2
	exit 2
fi
Y=${OTHER_VLS_NOS}
echo "Route to be added for the network number(s) $Y"
echo -n "Press ENTER to continue ... "
read dummy

# Add new route
for y in $Y
do
	if [ "$X" -ne "$y" ]
	then
	    nmcli con modify ens192 +ipv4.routes "192.168.${y}.0 172.20.${y}.1 100"
	    echo "Adding route to 192.168.${y}.0 network." 
	fi
done
nmcli con down ens192
nmcli con up ens192
ip route show
 
# enable IP forwarding on the gateway, add "net.ipv4.ip_forward = 1" to /etc/sysctl.conf 
echo "1" > /proc/sys/net/ipv4/ip_forward
