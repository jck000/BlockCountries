#!/bin/bash

# This script will block IP addresses coming from specific countries.  It uses a 
#   config file for it's settings.
#
# See url for more info - http://www.cyberciti.biz/faq/?p=3402
# Author: nixCraft <www.cyberciti.biz> under GPL v.2.0+
# -------------------------------------------------------------------------------

. ./block_countries.conf

# If this is not a terminal, redirect output
if [ ! -t 0 ] ; then
  LOGDATE="`date +'%Y%m%d'`"; export LOGDATE
  exec >> "$LOGDIR/$0.runlog.$LOGDATE"
  exec 2>&1
fi

usage() {
  echo "Usage:$0\n\n"
  exit
}

ipt() {
  echo -e "ipt\n"
}

fwc() {

  IFS=","
  for c  in $COUNTRY_LIST ; do
    zone="`echo $c|cut -d':' -f1`"
    zone_name="`echo $c|cut -d':' -f2`"

    # local zone file
    tDB=$DL/$zone.zone
   
    # get fresh zone file
    $WGET -O $tDB $DLROOT/$zone.zone
   
    $FWC --permanent --delete-zone=$zone
   
    # get 
    BADIPS=$(egrep -v "^#|^$" $tDB)
    
    echo -e "Creating new zone $zone\n"
    $FWC --permanent --new-zone="$zone"
    $FWC --permanent --zone=$zone --set-target="DROP"
    $FWC --permanent --zone=$zone --set-short="$zone_name"
    $FWC --permanent --zone=$zone --set-description="Unsolicited incoming network packets from $zone_name are dropped. Incoming packets that are related to outgoing network connections are accepted. Outgoing network connections are allowed."

    unset IFS
    for ipblock in $BADIPS; do
      echo "$zone $ipblock   "
      $FWC --permanent --zone=$zone --add-source=$ipblock
    done
  done

  $FWC --set-default-zone=$zone
  $FWC --reload

  # Drop everything 

}

if [ -n "$FWC" ] ; then
  fwc
elif [ -n "$IPT" ] ; then
  ipt
else 
  echo -e "Error: You have not defined which version of \n\n"
  usage
fi

exit 0





