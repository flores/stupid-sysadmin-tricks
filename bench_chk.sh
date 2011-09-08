#!/bin/bash
# Gets times to load different elements of the somesite.  Can be used for any 
# cp server as long as one first makes a cookie.site file for authentication 
# (ex: cookie.somesite.com)
# -- lo

if [ ${#1} = 0 ]; then
	echo "$0 site"
	exit 1
fi

SITE=$1
CURL="curl -w %{time_total} -c ~/cookie.$SITE -b ~/cookie.$SITE -s"

LOGIN=$($CURL "http://$SITE/some.cgi?do=login")
MENU=$($CURL "http://$SITE/some.cgi?do=aa\&edit_callmenu=1")
STATS=$($CURL "http://$SITE/some.cgi?do=status\&main_tab=1&resources=1")
EXT=$($CURL "http://$SITE/some.cgi?do=ext\&list_ext=all")

# Makes a random month, to prevent db caching of report
MON=0
while [ "$MON" -lt 1 ] 
do
	MON=$RANDOM
	let "MON %= 12"
done

REPORT=$($CURL "http://$SITE/some.cgi?do=rep\&showinbound=on&showoutbound=on&src=on&dst=on\&disposition=on\&calldate=on\&duration=on&from=\&to=\&for_ext=\&call_records_per_page=30\&reporting=1\&month1=$MON\&day1=20\&year1=2007\&month2=3\&day2=20\&year2=2008")

# CSV friendly
echo -e "$DATE,$TIME,$LOGIN,$MENU,$EXT,$REPORT,$STATS"
