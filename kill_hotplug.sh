for i in `/bin/ps aux | /bin/grep hotplug | /bin/awk '{print $2};'`;do /bin/kill -9 $i; done
