#!/bin/bash

DISK_USAGE=$(df -hT | grep -v Filesystem)
DISK_THRESHOLD=1
MSG=" "
while IFS= read line
do
    USAGE=$(echo $line | awk '{print $6f}' | cut -d "%" -f1)
    PARTITION=$(echo $line | awk '{print $7f}')
    if [ $USAGE -ge $DISK_THRESHOLD ]
    then
        MSG+="High Disk Usage on $PARTITION: $USAGE"
    fi
done <<< $DISK_USAGE
echo -e $MSG