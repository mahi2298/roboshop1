#!/bin/bash

source ./common.sh
app_name=shipping
check_root

echo "Please enter root password to setup"
read -s MYSQL_SERVER_PASSWORD

app_setup

system_setup

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

systemctl restart $app_name &>>$LOG_FILE
VALIDATE $? "restarting the $app_name service"