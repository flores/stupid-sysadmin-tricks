#!/bin/bash
# Compares routing to table to /etc/rc.local, 
# attempts to autoheal missing routes.  

HOST=`/bin/hostname`

# Grab current routes, do not count gateway.
ROUTES=$(/sbin/route -vn | /bin/awk 'and($1 !~ /0.0.0.0|[a-z]/, $2 !~ /0.0.0.0/) {print $1}'| sort)
# Grab rc.local's routes, ignore any commented lines and sed out subnet
RCLOCAL=$(/bin/awk '$1 ~ /^\/sbin\/route/ {print $4}' /etc/rc.local | /bin/sed 's/\/\(8\|2[1-9]\)//g' | /bin/sort)

# get stuff from routing table not in /etc/rc.local, then email to systeam
MISS=$(/usr/bin/diff <(printf '%s\n' "$ROUTES") <(printf '%s\n' "$RCLOCAL"))
if [ ${#MISS} -gt 0 ]; then
	(
		/bin/echo "CRITICAL: Routes do not match"
		exit 2
	)
else
	( 
		/bin/echo "OK"
		echo 0
	)
fi
