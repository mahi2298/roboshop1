#!/bin/bash
source ./common.sh
app_name=redis
check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling the redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling the redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing the redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf # if they are multiples expressions we need to use -e twice
#sed -i 's/protected-mode:yes/protectedmode:no/g' /etc/redis/redis.conf
systemctl restart redis &>>$LOG_FILE

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling the redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting the redis"

print_value