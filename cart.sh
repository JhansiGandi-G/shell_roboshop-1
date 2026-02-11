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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling NodeJs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enaabling NodeJs with 20 version"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install NodeJS"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading cart code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "Uzip cart code"

npm install  &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $CURRENT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable cart  &>>$LOGS_FILE
systemctl start cart
VALIDATE $? "Starting and enabling cart"