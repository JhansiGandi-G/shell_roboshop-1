#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop-1"
LOGS_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if  [ $USERID -ne 0 ]; then
    echo -e " $R please run the script from root user $N" | tee -a $LOGS_FILE
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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "coping mongo db repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing Mongodb server"

systemctl enable mongod &>>$LOGS_FILE 
VALIDATE $? "Enabling Mongodb server"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Starting Mongodb server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "Allowing remote connections"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restarting Mongodb server"
