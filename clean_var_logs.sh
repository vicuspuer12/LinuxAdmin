#!/bin/bash
$dtr1={service directory with logs}
$dtr2={service directory with logs}
$dtr3={service directory with logs}
$dtr4={service directory with logs}
$dtr5={service directory with logs}
cd /var/log/$dtr1 && truncate -s 0 *.log && cd /var/log/$dtr2 && truncate -s 0 *.log && cd /var/log/$dtr3 && truncate -s 0 *.log && cd /var/log/$dtr4 && truncate -s 0 *.log && cd /var/log/$dtr5 && truncate -s 0 *.log && cd .. && truncate -s 0 *.log && truncate -s 0 debug && truncate -s 0 syslog && truncate -s 0 *.1
echo "******Done Cleaning Nifty Log******"
