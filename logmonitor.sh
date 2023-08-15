#!/bin/bash

err="Pthread Error"

tail -f -n 100 /var/log/firebird/firebird.log |
while read line
do
    if [[ "$line" =~ $err ]]; then
        --journald "detected PTHREAD error - restarting firebird"
        systemctl restart firebird
    fi
done

# this Scripts checks for PThread Error on a runing Firebird database server by checking the database log entries.
