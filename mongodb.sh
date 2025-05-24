#!/bin/bash

source ./common.sh
check_root

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

print_value