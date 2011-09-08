#!/usr/bin/env bash

for keys in ~/keydir/*; do ssh-add $keys; done

function go () { 
  ssh root@$* || 
  ssh root@$*\.whateverdomain.com || 
  ssh someuser@$*\.whatever.com || 
  ssh root@$*\.someinternalbox.int; }

# use it like 'go box' or 'go host.somedomain.com' or whatever.
# could use some logic i guess..
