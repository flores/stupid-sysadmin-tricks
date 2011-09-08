#!/bin/bash 

# just checks md5sum of file, to see if 
# loadbalancing or some other thing is 
# corrupting the file -- carlo

/usr/bin/wget http://somefile
CHECK=$(/usr/bin/md5sum ./somefile |/bin/awk '{print $1}')

if [ "$CHECK" = 'somemd5sum' ]; then
	echo "OK"
	exit 0
else
	echo "CRITICAL"
	exit 2
fi

/bin/rm -f ./somefile*
