# zabbix-pushover

A Zabbix alertscript for pushover with priority and embedded image graphs

_a Zabbix notification on the Pushover app on a iPhone._

![ios](https://github.com/dkruyt/resources/raw/master/pushover_ios_small.png)


## cli usage
```
notify_pushover.sh 'Pushover_Userkey|Pushover_apptoken' 'subject' 'message'
```
## Install

Copy notify-pushover.sh to AlertScriptsPath from /etc/zabbix/zabbix_server.conf

Adjust the following configs in the script

```
# Zabbix address
ZBX_URL="https://zabbixserver"

# Zabbix credentials to login
USERNAME="zabbixuser"
PASSWORD="password"
```

Optional adjust the following

```
# Image time and size
PERIOD=24h
WIDTH=800
# invert image, better for black theme pushover and better for your eyes at night.
INV=true
```

## Configure Actions

Under *configuration -> actions* in Zabbix create or change the notification messages to the folowing. The subject wil be used for the Pushover Priority. These Priority levels can be adjusted if needed in the bash script. Item Graphic will be used to extract a image from Zabbix en added to the Pushover message.

#### Operations

Default subject:
```
{TRIGGER.SEVERITY}: {EVENT.NAME}
```
Default message:
```
Hostname: {HOSTNAME}
Problem: {TRIGGER.NAME}:
Problem started at {EVENT.TIME} on {EVENT.DATE}

Severity: {EVENT.SEVERITY}

Last tested value: {{HOSTNAME}:{TRIGGER.KEY}.last(0)}
Item values: {ITEM.NAME1} ({HOST.NAME1}): {ITEM.VALUE1}

Item Graphic: [{ITEM.ID1}]
```
#### Recovery operations

Default subject:

```
Resolved: {EVENT.NAME}
```

Default message:
```
Hostname: {HOSTNAME}
Problem name: {EVENT.NAME}
Problem status: {STATUS}

Last tested value: {{HOSTNAME}:{TRIGGER.KEY}.last(0)}
Item values: {ITEM.NAME1} ({HOST.NAME1}): {ITEM.VALUE1}
```
#### Update operations

Default subject:
```
Updated problem: {EVENT.NAME}
```
Default message:
```
{USER.FULLNAME} {EVENT.UPDATE.ACTION} problem at {EVENT.UPDATE.DATE} {EVENT.UPDATE.TIME}.

{EVENT.UPDATE.MESSAGE}

Current problem status is {EVENT.STATUS}, acknowledged: {EVENT.ACK.STATUS}.
```
## Configure media type

Under *Administration -> Media* in Zabbix add a new media. Specify the name of the script in script name and check that the parameters are correct.

![mediatype](https://github.com/dkruyt/resources/raw/master/zabbix-mediatype.png)

## Configure user media

You will need then to add the media to your users. For this just edit an user and add a media selecting the one you just created before. Specify the UserKey and AppToken in the Send to field, separated by a | .

![usermedia](https://github.com/dkruyt/resources/raw/master/zabbix-usermedia.png)


