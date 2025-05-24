#!/bin/bash
USERID=$(id -u)

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
    useradd --system --home /app --sh /sbin/nologin --comment "Roboshop user" roboshop
    VALIDATE $? "Creating the Roboshop user "
else
    echo "$Y Roboshop user is already created $N"
fi

mkdir -p /app
VALIDATE $? "Creating the /app directory "

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the Zip File"


rm -rf /app/*
VALIDATE $? "Removing the default content"

cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping file"

npm install &>>$LOG_FILE
VALIDATE $? "Installing the dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying the catalogue service"

systemctl daemon-reload 
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "Starting the catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing the mongodb Client"

STATUS=$(mongosh --host mongodb.pavithra.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.pavithra.fun </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading the data into MongoDB"
else
    echo "Data is already loaded ... $Y SKIPPING $N"
fi