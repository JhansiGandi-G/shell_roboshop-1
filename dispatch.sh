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

dnf install golang -y &>> $LOGS_FILE
VALIDATE $? "Installing Golang"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGS_FILE

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading dispathing"

cd /app &>>$LOGS_FILE

unzip /tmp/dispatch.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping dispathing"

cd /app &>>$LOGS_FILE
go mod init dispatch &>>$LOGS_FILE
go get &>>$LOGS_FILE
go build &>>$LOGS_FILE
VALIDATE $? "building dispathing"

systemctl daemon-reload &>>$LOGS_FILE

systemctl enable dispatch &>>$LOGS_FILE
VALIDATE $? "enabling dispathing"

systemctl start dispatch &>>$LOGS_FILE
VALIDATE $? "disabling dispathing"