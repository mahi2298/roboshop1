#!/bin/bash
USERID=$(id -u)
START_TIME=$(date +%s)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.logs"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started execution at:: $(date)"
if [ $USERID -ne 0 ]
then
    echo "$R ERROR:: Please run the script with root user $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running the script with root user" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo "$2 is .... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo "$2 is .... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling the Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling the Nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing the Nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --sh /sbin/nologin --comment "Roboshop user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating the Roboshop user"
else
    echo "User is already created"
fi

mkdir -p /app
VALIDATE $? "Creating the app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the File"

rm -rf /app/*
cd /app
unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the user File"

npm install &>>$LOG_FILE
VALIDATE $? "Installing the dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying the user service"

systemctl daemon-reload
systemctl enable user &>>$LOG_FILE
systemctl start user
VALIDATE $? "Starting the user service"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo "Script executed in $TOTAL_TIME seconds"