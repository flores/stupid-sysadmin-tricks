#!/bin/bash

# checks if nfs is mounted. 

mount |grep somesharename
EXIT=$?

if [ $EXIT -eq 0 ]; then
	echo "OK"
	exit $EXIT
else
	echo "CRITICAL"
	exit 2
fi
