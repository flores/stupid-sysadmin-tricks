#!/bin/bash

# Grab current routes, do not count gateway.
ROUTES=$(/sbin/route -vn | awk 'and($2 !~ /0.0.0.0|[a-z]/, $1 !~ /0.0.0.0/) {print $1}'|sort)

# Grab rc.local's routes, ignore any commented lines and sed out subnet
RCLOCAL=$(awk '$1 ~ /^\/sbin\/route/ {print $4}' /etc/rc.local | sed 's/\/2[1-9]//g' | sort)

# Count the difference
DIFF=$(diff <(printf '%s\n' "$ROUTES") <(printf '%s\n' "$RCLOCAL"))

if $#DIFF
