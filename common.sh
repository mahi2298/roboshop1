#!/bin/bash

USERID=$(id -u)
START_TIME=$(date +%s)
R="\e[31m" 
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.logs"
SCRIPT_DIR=$PWD
mkdir -p $LOG_FOLDER
echo "Script started executing at $(date)" | tee -a $LOG_FILE
    
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run the script with Root user $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "You are running the script with root user" | tee -a $LOG_FILE
    fi
}

app_setup(){
    id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --sh /sbin/nologin --comment "Roboshop user" roboshop
        VALIDATE $? "Creating the Roboshop user"
    else
        echo "$Y Roboshop user is already created $N"
    fi

    mkdir -p /app
    VALIDATE $? "Creating the /app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading the $app_name Zip File"


    rm -rf /app/*
    VALIDATE $? "Removing the default content"

    cd /app 
    unzip /tmp/$app_name.zip
    VALIDATE $? "Unzipping the $app_name file"
}

nodejs_Setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling the Nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling the Nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing the Nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing the dependencies"
}

system_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying the catalogue service"

    systemctl daemon-reload 
    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Starting the $app_name"
}
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ..... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ..... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

print_value(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo "Script executed in $TOTAL_TIME seconds"
}