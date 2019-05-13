#!/bin/bash

# Pushover notify script for Zabbix with prio and inline image by Dennis Kruyt <dennis@kruyt.org>

# Zabbix address
ZBX_URL="https://zabbixserver"

# Zabbix credentials to login
USERNAME="zabbixuser"
PASSWORD="password"

# Image time and size
PERIOD=24h
WIDTH=800
# invert image, better for black theme pushover and better for your eyes at night.
INV=true

# Get arguments
USER=$1
SUBJECT=$2
TEXT=$3

# Get TOKEN from USER
TOKEN=$(echo $USER | awk -F"|" '{print $2}')
USERTOKEN=$(echo $USER | awk -F"|" '{print $1}')

CURL="/usr/bin/curl"
CONVERT="/usr/bin/convert"

# Get graphid from text
GRAPHID=$(echo $TEXT | grep -o -E "(Item Graphic: \[[0-9]{7}\])|(Item Graphic: \[[0-9]{6}\])|(Item Graphic: \[[0-9]{5}\])|(Item Graphic: \[[0-9]{4}\])|(Item Graphic: \[[0-9]{3}\])")
GRAPHID=$(echo $GRAPHID | grep -o -E "([0-9]{7})|([0-9]{6})|([0-9]{5})|([0-9]{4})|([0-9]{3})")

# Set cookie
COOKIE="/tmp/zabbix.cookie"

# Set tmp image
PNG_PATH="/tmp/zabbix-image.png"

# Get severity and set prio
SEVERITY=$(echo $SUBJECT | awk -F":" '{print $1;}')

case $SEVERITY in
	"Not classified") PRIO="-2";;
	"Information") PRIO="-2";;
	"Resolved") PRIO="-1";;
	"Warning") PRIO="0";;
	"Average") PRIO="0";;
	"High") PRIO="2";;
	"Disaster") PRIO="2";;
	*) PRIO="0";;
esac

ARGS+=( -F "priority=$PRIO" )

# EMERGENCY PRIORITY
if [[ $PRIO == 2 ]]
then
  ARGS+=( -F "retry=3600" )
  ARGS+=( -F "expire=120" )
fi


# Test if we have a GRAPHID, if not send notification without image
if [ -z $GRAPHID ]
    then
        # Send notification
        ${CURL} -s -F "token=${TOKEN}" -F "user=${USERTOKEN}" -F "message=${TEXT}" https://api.pushover.net/1/messages.json
    else
        # Log in and get Cookie
        ${CURL} -k -s -S --max-time 5 -c ${COOKIE} -b ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Sign%20in" ${ZBX_URL}"/index.php"
        # Get Image and store in tmp
        ${CURL} -k -s -S --max-time 5 -c ${COOKIE}  -b ${COOKIE} -d "itemids=${GRAPHID}&from=now-${PERIOD}&to=now&width=${WIDTH}&profileIdx=web.graphs.filter" ${ZBX_URL}"/chart.php" -o "${PNG_PATH}";

				if [[ $INV == true ]]
					then
						# invert image, better for black theme pushover and better for your eyes at night.
						${CONVERT} ${PNG_PATH} -channel RGB -negate ${PNG_PATH}
				fi

        # Send notification
        ${CURL} -s -F "token=${TOKEN}" "${ARGS[@]}" -F "user=${USERTOKEN}" -F "message=${TEXT}" -F "attachment=@${PNG_PATH}" https://api.pushover.net/1/messages.json

				# Cleanup
				# rm old cookie
				rm $COOKIE
				# rm old image
				rm $PNG_PATH
fi