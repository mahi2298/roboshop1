#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_Setup
system_setup

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

print_value