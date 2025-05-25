#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/logs/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SOURCE_DIR=/home/ec2-user/app-logs/sourcedir
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
USERID=$(id -u)
if [ $USERID -ne 0 ]
then 
    echo "ERROR:: Please run the script with root access" | tee -a $LOGS_FILE
    exit 1
else
    echo "You are Running with root access"
fi

echo "Script started executing at $(date)"

FILES_TO_DELETE=$(find $SOURCE_DIR -name "*.log" -mtime +14)
while IFS= read -r filepath
do
    echo "Deleting file: $filepath"
    rm -rf $filepath
done <<< $FILES_TO_DELETE

echo "Script executed successfully"
