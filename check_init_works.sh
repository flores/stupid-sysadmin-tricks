#!/usr/bin/env bash

check_health() { # arg should be port
  url="http://127.0.0.1:$1/health_check.html"
  if curl -s $url | grep OK; then
    return 0
  else
    return 1
  fi
}

check_running() { # arg should be role
  echo `ps -ef |grep $1 |awk '/$product/ && !/awk/ {print $2}'`
}
# yadda yadda

status=0

# does stop work?

backend_ports=`$serverinfo backend-ports`

$script stop > /dev/null 2>&1
sleep 60 # stop is slow

for i in `check_running be`; do
  echo "ERROR: $product is still running on pid $i after stop!"
  status=1
done

# can we curl the stats page?
for i in $backend_ports; do
  health=`check_health $i`
  if [ "$health" -ne 1 ]; then
    echo "ERROR: $product is still responding to port $i"
    status=1
  fi
done

# does start work?

$script start > /dev/null 2>&1
sleep 60 

pids_starttest=`check_running be`

if [ -z "$pids_starttest" ]
  echo "ERROR: $product is not running after start!"
  status=1
fi

for i in $backend_ports; do
  health=`check_health $i`
  if [ "$health" -ne 0 ]; then
    echo "ERROR: $product is not responding on port $i"
    status=1
  fi
done

# does restart work?
$script restart > /dev/null 2>&1
sleep 120

pids_restarttest=`check_running be`
if [ "$pids_restarttest" -eq "$pids_starttest" ]; then
  echo "ERROR: sailfish did not restart!"
  status=1
fi

for i in $backend_ports; do
  health=`check_health $i`
  if [ "$health" -ne 0 ]; then
    echo "ERROR: $product is not responding to healthcheck on $i after restart"
    status=1
  fi
done 

exit $status
