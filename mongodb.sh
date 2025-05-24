#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.logs"
mkdir -p $LOG_FOLDER
echo "Script started executing at $(date)" | tee -a $LOG_FILE
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run the script with Root user $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e "You are running the script with root user" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ..... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ..... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying the Repo file"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing the mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling the mongodb"

systemctl start mongod
VALIDATE $? "Starting the mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing the Mongodb file for remote connection"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting the MONGODB File"