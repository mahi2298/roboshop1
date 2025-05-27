#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)
LOGS_FOLDER="/var/logs/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]
then 
    echo "ERROR:: Please run the script with root access" | tee -a $LOGS_FILE
    exit 1
else
    echo "You are Running with root access"
fi

echo "Script started executing at $(date)"

USAGE(){
     echo -e "$R USAGE:: $N sh 20-backup.sh <source-dir> <destination-dir> <days(optional)>"
     exit 1
}
if [ $# -lt 2 ]
then
    USAGE
fi

if [ ! -d $SOURCE_DIR ]
then
    echo -e "$R Source Directory $SOURCE_DIR does not exist. Please check $N"
    exit 1
fi

if [ ! -d $DEST_DIR ]
then
    echo -e "$R Destination Directory $DEST_DIR does not exist. Please check $N"
    exit 1
fi

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +$DAYS)
if [ ! -z "$FILES" ]
then
    echo "Files to zip are: $FILES"
    TIME_STAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/app-logs-$TIME_STAMP.zip"
    find $SOURCE_DIR -name "*.log" -mtime +$DAYS | zip -@ $ZIP_FILE
    echo "Files zipped successfully $ZIP_FILE"
else
    echo -e "No other files found older than 14 days ... $Y SKIPPING $N"
fi