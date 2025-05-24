#!/bin/bash


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

START_TIME=$(date +%s)
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.logs

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

echo "Please enter root password to setup"
read -s MYSQL_SERVER_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing the mysql-server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling the mysql-server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting the mysql-server"

mysql_secure_installation --set-root-pass $MYSQL_SERVER_PASSWORD
VALIDATE $? "Setting up the password for mysql server"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo "Script executed at :: $TOTAL_TIME seconds"