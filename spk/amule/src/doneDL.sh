#!/bin/sh
#
# doneDL.sh - sends an email upon completion of an aMule download
# Used in conjuction with aMule's Event feature
#
# Call like this: doneDL.sh "%NAME" "%FILE" %HASH %SIZE "%DLACTIVETIME"
#
# Enter your email address here:
eMail="Enter your email address here"
#
NameShort=$1
NameLong=$2
Hash=$3
Size=$4
DLtime=$5
{
echo "Subject: $NameShort"
echo
echo aMule completed this download:
echo ------------------------------
echo
echo File: "$NameLong"
echo Hash: $Hash
echo -n "Time: "
# date | awk '{print $6 " " $4}'
date +%F' '%T
echo -n Size: $Size bytes
if [ $Size -gt 102400 ] ; then echo " ("$(($(($Size / 1024)) / 1024)) "Mb)" ; fi
if [ ! -z "$DLtime" ] ; then echo "Active download time:" $DLtime ; fi
echo
echo --------------------------------------------------------------------
# cas
# echo -n "Resident memory: "
# echo $(ps amule-daemon | awk '{print $6}') kB
echo -n "Virtual memory:  "
# echo $(ps amule-daemon | awk '{print $5}') kB
echo $(ps | grep [a]mule-daemon | awk '{print $3}')
echo --------------------------------------------------------------------
} | sendmail -F "Synology Station Download" -f $eMail -t $eMail

