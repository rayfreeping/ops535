# get zone file name from named.conf
# $1 - config file named.conf
# return zone file name
if [ $# -eq 0 ]
then
	echo "plase supply named config file." >&2
	exit 1
fi

if [ ! -f $1 ]
then
	echo "can not find named config file $1." >&2
	exit 2
fi

echo "Processing named config file $1" >&2

tline=$(wc -l $1|awk '{print $1}') # total number of line
zlines=$(grep -n 'zone ' $1|awk -F: '{print $1}') # lines start with 'zone '
base_dir=$(grep -v 'keys-directory' $1|grep 'directory'| awk -F\" '{print $2}')

echo "Base directory $base_dir " >&2

if [ "$zlines" != "" ]
then
   zonefiles=""
   for zline in ${zlines}
   do
      zline_keep=$((tline-zline+1))
      lines2keep=$(tail -${zline_keep} $1)
      zline_end=$(echo "$lines2keep"| grep -n '};'|head -1|awk -F: '{print $1}')
      zone_data=$(echo "$lines2keep"| head -$zline_end)
      zone_fn_line=$(echo "$zone_data"| tr -d '\n'| awk -F\; '{print $2}')
      zone_filename=$(echo $zone_fn_line|awk -F\" '{print $2}')
      
      zonefiles="$zonefiles "$zone_filename
      echo "Zone files: $zonefiles" >&2
    done

      echo $zonefiles
fi
