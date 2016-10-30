# script name: a1-conf.sh
# created by: Raymond Chan
# last update on: Oct 22, 2016
# 
# Check UID
uid=$(id -u)
if [ "$uid" -ne 0 ]
then
	echo "You must run this script as root."
	exit 1
fi

# Network Configuration
IPS=$(ip addr | grep "inet" | grep "global"|awk '{print $2}')
MACS=$(ip addr| grep "link/ether" |awk '{print $2}')
OPS_HN=$(hostname)
KERNEL_RT=$(ip route sh)

# Hardware Information
BLOCK_DEVICE=$(blockdev --report)

# System log
SYS_LAST=$(last)

# Service configuration at system boot
PORTMAP=$(systemctl list-unit-files | grep rpcbind.service)
YPSERV=$(systemctl list-unit-files | grep ypserv.service)
BIND=$(systemctl list-unit-files | grep named)
YPBIND=$(systemctl list-unit-files | grep ypbind.service)
NIS=$(systemctl list-unit-files | grep nfs)

# active service
YPSERV_S=$(systemctl status ypserv.service)
BIND_S=$(systemctl status named.service)
YPBIND_S=$(systemctl status ypbind.service)
NFS_S=$(systemctl status nfs-server.service)
IPTABLES_S=$(systemctl status iptables.service)
PORTMAP_S=$(rpcinfo -p)

#firewall setting
FIREWALL=$(iptables-save)

#collect configuration file
NSSWITCH=$(cat /etc/nsswitch.conf)
RESOLV=$(cat /etc/resolv.conf)

NFS_EXPORT=
systemctl status nfs-server.service > /dev/null
if [ "$?" -eq 0 ]
then 
	NFS_EXPORT=$(cat /etc/exports)
fi

NAMED_CONF=
systemctl status named.service > /dev/null
if [ "$?" -eq 0 ]
then
	ROOTDIR=$(grep -v ^# /etc/sysconfig/named|grep ROOTDIR | awk -F= '{print $2}')
	named_conf_file=${ROOTDIR}/etc/named.conf
	NAMED_CONF=$(cat ${named_conf_file})
	# processing named.conf file
	tline=$(wc -l $named_conf_file|awk '{print $1}') # total number of line
	zlines=$(grep -n 'zone ' $named_conf_file|awk -F: '{print $1}') # lines start with 'zone '
	base_dir=$(grep -v 'keys-directory' $named_conf_file |grep 'directory'| awk -F\" '{print $2}')

	echo "Base directory $base_dir " >&2

	if [ "$zlines" != "" ]
	then
	   zonefiles=""
	   for zline in ${zlines}
	   do
	      zline_keep=$((tline-zline+1))
	      lines2keep=$(tail -${zline_keep} $named_conf_file)
	      zline_end=$(echo "$lines2keep"| grep -n '};'|head -1|awk -F: '{print $1}')
	      zone_data=$(echo "$lines2keep"| head -$zline_end)
	      zone_fn_line=$(echo "$zone_data"| tr -d '\n'| awk -F\; '{print $2}')	
	      zone_filename=$(echo $zone_fn_line|awk -F\" '{print $2}')
	      
	      zonefiles="$zonefiles "$zone_filename
	      echo "Zone files: $zonefiles" >&2
	    done
	
	      echo $zonefiles >&2
	fi
	# processing zone file(s)
	if [ "$zonefiles" != "" ]
	then
	   ZONE_CONTENTS=
           for zonefile in ${zonefiles}
	   do
	     zone_file_name=${ROOTDIR}${base_dir}/${zonefile}
	     ZONE_CONTENTS=$(echo -e "${ZONE_CONTENTS}\nZone File Name:${zone_file_name}\n\n$(cat $zone_file_name)\n\n\n")
		
	   done # processing zonefile
	fi # end processing zone file(s)
fi


MAKEFILE=
MAP_FILES=
systemctl status ypserv.service > /dev/null
if [ "$?" -eq 0 ]
then
	MAKEFILE=$(cat /var/yp/Makefile)
	NIS_DOMAIN=$(domainname)
	MAP_FILES=$(ls /var/yp/${NIS_DOMAIN})
fi

YPBIND_CONF=
systemctl status ypbind.service > /dev/null
if [ "$?" -eq 0 ]
then
	YPBIND_CONF=$(cat /etc/yp.conf)
	NIS_DOMAIN=$(domainname)
fi

# mount file system
MOUNT=$(mount)
	
# generating the report
echo "============================================================================="
echo "A1 Report started on $(date) for ${OPS_HN} "
echo "============================================================================="
echo "Networking Configuration"
echo "------------------------"
echo "${IPS}"
echo "${MACS}"
echo "${OPS_HN}"
echo "${KERNEL_RT}"
echo "****"

echo "System Information"
echo "------------------"
echo "--- Block Device ---"
echo "${BLOCK_DEVICE}"
echo "--- System Activities ---"
echo "${SYS_LAST}"
echo "****"

echo "Service boot time configuration"
echo "-------------------------------"
echo "${PORTMAP}"
echo "${YPSERV}"
echo "${BIND}"
echo "${YPBIND}"
echo "${NFS}"
echo "****"

echo "Current Service status"	
echo "----------------------"
echo "==Port Mapper=="
echo "${PORTMAP_S}"
echo "==NIS Server=="
echo "${YPSERV_S}"
echo "==DNS Server=="
echo "${BIND_S}"
echo "==NIS Client=="
echo "${YPBIND_S}"
echo "==NFS Server=="
echo "${NFS_S}"
echo "==Firewall=="
echo "${IPTABLES_S}"
echo "****"

echo "System configurations"
echo "---------------------"
echo "==Name Service Switch=="
echo "${NSSWITCH}"
echo "==DNS Client=="
echo "${RESOLV}"
echo "==Firewall=="
echo "${FIREWALL}"

echo "Server Configurations"
echo "---------------------"
echo "==DNS Server Configuration=="
echo "----------------------------"
echo "BIND chroot: ${ROOTDIR}/"
echo "${NAMED_CONF}"
echo "--- ZONE data ---"
echo "-----------------"
echo "${ZONE_CONTENTS}"
echo "==NIS Server Configuration=="
echo "----------------------------"
echo "${MAKEFILE}"
echo "${NIS_DOMAIN}"
echo "${MAP_FILES}"
echo "==NIS Client Configuration=="
echo "----------------------------"
echo "${YPBIND_CONF}"
echo "${NIS_DOMAIN}"
echo "==NFS Sever Configuration=="
echo "${NFS_EXPORT}"
echo "== Mounted file system =="
echo "${MOUNT}"

echo "============================================================================="
echo "A1 Report completed on $(date) for ${OPS_HN} "
echo "============================================================================="
