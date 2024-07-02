#!/bin/bash
directory="/var/log"
rangedate="2024-06-30"
find "$directory" -name *.log -type f ! -newermt "$rangedate" -delete
echo "Files older than $rangedate have been deleted."
