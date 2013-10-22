#!/usr/bin/env bash
for user in $(getent passwd | cut -f1 -d:); do crontab -u $user -l; done
