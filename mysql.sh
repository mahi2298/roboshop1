#!/bin/bash

source ./common.sh
app_name=mysql

check_root

echo "Please enter root password to setup"
#read MYSQL_SERVER_PASSWORD 
read -s MYSQL_SERVER_PASSWORD    #password:RoboShop@1

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing the mysql-server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling the mysql-server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting the mysql-server"

mysql_secure_installation --set-root-pass $MYSQL_SERVER_PASSWORD
VALIDATE $? "Setting up the password for mysql server"

print_value