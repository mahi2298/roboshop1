#!/bin/bash


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

START_TIME=$(date +%s)
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.logs
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started execution at :: $(date)" | tee -a $LOG_FILE
USERID=$(id -u)
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
        echo "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing the python3"

id roboshop 
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating the new user"
else
    echo "User is already Created"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "Creating the app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the payment file"

rm -rf /app/*
cd /app
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the payment file"
 
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing the python dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copyting the file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-Reload"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enabling the payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting the payment"