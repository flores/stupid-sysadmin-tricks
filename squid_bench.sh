#!/bin/bash

# Adapted for squid testing. - lo@somehost.com 6/27/2008

# Gets times to load different elemnts of the cps.  Can be used for any 
# cp server as long as one first makes a cookie.site file for authentication 
# -- lo

if [ ${#1} -lt 2 ]; then
	echo "$0 <squid ip> <site/target host>"
	exit 1
fi

IP=$1
SITE=$2
WGET="/usr/bin/time -f %e -o /tmp/time wget --load-cookies cookie.squid.$SITE --header=Host:$SITE"
#-O /dev/null -q"
TIME="cat /tmp/time"
DATE=$(date +%H:%M' '%m-%d-%y)

if [[ "$SITE" =~ "somesite1.com" ]]; then
	USER="user"
	PASS="pass"
elif [ $SITE = 'somesite2.com' ]; then
	USER="user"
	PASS="pass"
elif [[ "$SITE" =~ "somesite.com" ]]; then
	USER="user"
	PASS="pass"
else 
	echo "not a valid site"
	exit 1
fi

#let's login and get our delicious cookie.  only using curl because it turns out having wget save the cookie fails
LOGIN=$(/usr/bin/time -f %e -o /tmp/time curl -c cookie.squid.$SITE -b cookie.squid.$SITE -H Host:$SITE "http://$IP/someresource" && $TIME)

MENU=$($WGET "http://$IP/someresource" && $TIME)
STATS=$($WGET "http://$IP/someresource" && $TIME)
EXT=$($WGET "http://$IP/someresource" && $TIME)

# Makes a random month, to prevent db caching of report
MON=$RANDOM
let "MON %= 11"
MON=$(expr $MON + 1)

REPORT=$($WGET "http://$IP/someresource" && $TIME)

# AWK because BASH does not play noice with floating points.  Printing literal \n for echo-e at mail
#PAGE=$(/bin/awk "BEGIN { 
#		if ( $LOGIN > 5 )  print \"login      $LOGIN\\n\";
#		if ( $MENU > 5 )   print \"edit menu  $MENU\\n\"; 
#		if ( $EXT > 5 )    print \"extensions $EXT\\n\"; 
#		if ( $STATS > 5 )  print \"status     $STATS\\n\"; 
#		}")

#if [ ${#PAGE} -gt 0 ]; then 
#	echo -e "page      time(secs)\n $PAGE" | mail -s "Slow $SITE" lo@somesite.com
#fi
	
## Cacti friendly
echo "login:$LOGIN menu:$MENU ext:$EXT report:$REPORT stats:$STATS"
#
## CSV friendly
#echo -e "$DATE,$TIME,$LOGIN,$MENU,$EXT,$REPORT,$STATS" >> ~lo/$SITE\_loadtimes









