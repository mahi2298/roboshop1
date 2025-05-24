#!/bin/bash
source ./common.sh
app_name=nginx
check_root

dnf module disable $app_name -y &>>$LOG_FILE
VALIDATE $? "Disabling the $app_name"

dnf module enable $app_name:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling the $app_name"

dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? "Installing the $app_name"

rm -rf /usr/share/$app_name/html/* 
VALIDATE $? "Removing the default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the Zip File"

cd /usr/share/$app_name/html 
unzip /tmp/frontend.zip
VALIDATE $? "Unzipping the frontend"

rm -rf /etc/$app_name/$app_name.conf &>>$LOG_FILE
VALIDATE $? "Removing the default nginx config"

cp $SCRIPT_DIR/$app_name.conf /etc/$app_name/$app_name.conf
VALIDATE $? "Copying the nginx conf"

systemctl restart $app_name &>>$LOG_FILE
VALIDATE $? "Restarting the $app_name service"

print_value