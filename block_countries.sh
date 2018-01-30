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

fwd() {

  IFS=" "
  for c  in $BLOCK_COUNTRIES ; do
    # local zone file
    tDB=$ZONEROOT/$c.zone
   
    # get fresh zone file
    $WGET -O $tDB $DLROOT/$c.zone
   
    # country specific log message
    SPAMDROPMSG="$c Country Drop "
   
    # get 
    BADIPS=$(egrep -v "^#|^$" $tDB)
    for ipblock in $BADIPS; do
      echo -e "$FWC --permanent --add-rich-rule=\"rule family='ipv4' source address='$ipblock' reject\""

    done
  done
   
  # Drop everything 

}

# create a dir
[ ! -d $DL ] && /bin/mkdir -p $DL

if [ -n "$FWC" ] ; then
  fwd() 
else if [ -n "$IPT" ] ; then

else 
  echo -e "Error: You have not defined which version of \n\n"
  usage();
fi

exit 0
