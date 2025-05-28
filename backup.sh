#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/logs/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}

mkdir -p $LOGS_FOLDER

USERID=$(id -u)
if [ $USERID -ne 0 ]
then 
    echo "ERROR:: Please run the script with root access" | tee -a $LOGS_FILE
    exit 1
else
    echo "You are running the script with Root user" | tee -a $LOGS_FILE
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
    echo -e "$R Source Directory $SOURCE_DIR Does not Exists. Please Check $N"
fi

if [ ! -d $DEST_DIR ]
then
    echo -e "$R Destination Directory $DEST_DIR Does not Exists. Please Check $N"
fi

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +$DAYS)
if [ ! -z "$FILES" ] # here -z stands for empty file but we are using ! -z non empty file
then
    echo "Files to zip are: $FILES"
    TIME_STAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/app-logs-$TIMESTAMP.zip"
    $FILES | zip -@ $ZIP_FILE
    if [ -z $ZIP_FILE ]
    then
        echo "Successfully created zip file"
        while IFS= read -r line
        do
            echo "Deleting Files: $line" | tee -a $LOG_FILE
            rm -rf $line
        done <<< $FILES
        echo -e "Log files older than $DAYS from source directory removed ... $G SUCCESS $N"
    else
        echo -e "Zip file creation ... $R FAILURE $N"
        exit 1
    fi
else
    echo -e "No other files found older than 14 days ... $Y SKIPPING $N"
fi