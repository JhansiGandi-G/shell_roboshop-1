#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop-1"
LOGS_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
CURRENT_DIR=$PWD


if  [ $USERID -ne 0 ]; then
    echo -e "$R please run the script from root user $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){

    if [ $1 -ne 0 ]; then
        echo -e "$R $2 ... failure $N" | tee -a $LOGS_FILE 
        exit 1
    else
        echo -e "$G $2 .. success $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable redis -y &>> $LOGS_FILE
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>> $LOGS_FILE
VALIDATE $? "enabling redis"

systemctl start redis &>> $LOGS_FILE
VALIDATE $? "disabling redis"