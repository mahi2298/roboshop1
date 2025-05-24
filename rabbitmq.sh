#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root

echo "Please Enter the Password to setup RabbitMQ"
read -s RABBITMQ_SERVER_PASSWORD


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying the repo file"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing the rabbitMQ Server"

systemctl restart rabbitmq-server &>>$LOG_FILE
VALIDATE $? "restarting the rabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling the rabbitMQ Server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting the rabbitMQ Server"

rabbitmqctl add_user roboshop $RABBITMQ_SERVER_PASSWORD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_value