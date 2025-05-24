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

echo "Please enter root password to setup"
read -s MYSQL_SERVER_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing the maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd --system --home /app --sh /sbin/nologin --comment "Roboshop user" roboshop
    VALIDATE $? "Creating the new user"
else
    echo "user is already created"
fi

mkdir -p /app
VALIDATE $? "Creating the /app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the shipping file"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the shipping file"


mvn clean package &>>$LOG_FILE
VALIDATE $? "Installing the maven dependencies"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "moving the shipping jar file to /app folder"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying the shipping service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling the shipping service"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting the shipping service"

dnf install mysql -y &>>$LOG_FILE


mysql -h mysql.pavithra.fun -u root -p$MYSQL_SERVER_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.pavithra.fun -uroot -p$MYSQL_SERVER_PASSWORD < /app/db/schema.sql
    mysql -h mysql.pavithra.fun -uroot -p$MYSQL_SERVER_PASSWORD < /app/db/app-user.sql 
    mysql -h mysql.pavithra.fun -uroot -p$MYSQL_SERVER_PASSWORD < /app/db/master-data.sql
    VALIDATE $? "Loading data into MySQL"
else
    echo "Data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "restarting the shipping service"