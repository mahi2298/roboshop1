#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

START_TIME=$(date +%s)
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


echo "Please Enter the Password to setup RabbitMQ"
read -s RABBITMQ_SERVER_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo "$2 is .... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo "$2 is .... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

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


END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo "Script executed at :: $TOTAL_TIME seconds"