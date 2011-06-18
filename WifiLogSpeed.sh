#!/bin/bash
# (c)Pieter E Smit 2011  - GPL-v3
# Monitors performance of wifi card, and dumps stats to file.
# Edit vars below.
dev="wlan0"
pingip="10.0.0.2"
filehistory="wifispeed.txt"
#History
#v1 - inital script
#v2 - more generic add vars
#v3 - add uniq and grep filter, can run more aggressive, only log low speed <100Mb/s
#v4 - shorten output
( 
  echo "`date +%T` , START - iwconfig monitor dev $dev"
  while true; do
    sleep 0.1 
    echo -n `date +%T`
    echo -n " , " 
    echo -n `iwconfig $dev | grep -o " Rate=.* Mb/s  \|Link Quality.*" `
    echo -n " , "
    ping $pingip -c 1 | grep -o " .\{1,3\}% packet loss"
  done
)  | stdbuf -oL uniq --count --skip-chars=10 \
   | grep -v --line-buffered --before-context=1 --after-context=1 \
          "Rate=300 Mb\|Rate=2.. Mb\|Rate=1.. Mb\|Rate=121.5 Mb" \
   | sed --unbuffered \
         -e 's/Link Quality/LQ/g;s/Signal level/Sig/g;s/packet loss/loss/g' \
   | tee --append $filehistory 

#THE END
