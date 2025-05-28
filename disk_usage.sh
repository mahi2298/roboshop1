#!/bin/bash

DISK_USAGE=$(df -hT | grep -v Filesystem)
DISK_THRESHOLD=1
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
MSG=""

while IFS= read line
do
    USAGE=$(echo $line | awk '{print $6f}' | cut -d "%" -f1)
    PARTITION=$(echo $line | awk '{print $7f}')
    if [ $USAGE -ge $DISK_THRESHOLD ]
    then
        MSG+="High Disk Usage on $PARTITION: $USAGE <br>"
    fi
done <<< $DISK_USAGE
#echo -e $MSG

sh mail.sh "Devops Team" "High Disk Usage" "$IP" "$MSG" "maheswarisanivarapu1999@gmail.com" "ALERT-High Disk Usage"