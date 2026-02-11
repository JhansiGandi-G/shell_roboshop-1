#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop-1"
LOGS_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
CURRENT_DIR=$PWD
MONGO_DB_HOST=mongodb.daws88s-jhansi.online

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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading user code"

cd /app &>> $LOGS_FILE
VALIDATE $? "moving to app directory"

unzip /tmp/user.zip &>> $LOGS_FILE
VALIDATE $? "Unzipping user code"


cd /app &>> $LOGS_FILE
VALIDATE $? "moving to app directory"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing dependecies"

cp $CURRENT_DIR/user.service /etc/systemd/system/user.service &>> $LOGS_FILE

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "User daemon reload"

systemctl enable user &>> $LOGS_FILE
VALIDATE $? "Enabling user"

systemctl start user &>> $LOGS_FILE
VALIDATE $? "Start user"