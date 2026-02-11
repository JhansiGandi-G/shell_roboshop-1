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

dnf module list nginx &>> $LOGS_FILE
VALIDATE $? "Listing nginx details"

dnf module disable nginx -y &>> $LOGS_FILE
VALIDATE $? "Disabling nginx details" 

dnf module enable nginx:1.24 -y &>> $LOGS_FILE
VALIDATE $? "Enabling nginx 24 details"

dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGS_FILE
VALIDATE $? "Systemctl enable nginx"

systemctl start nginx &>> $LOGS_FILE
VALIDATE $? "Systemctl start nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
VALIDATE $? "removing html file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading roboshop file"

cd /usr/share/nginx/html 

unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "unzipping froned file"

cp $CURRENT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOGS_FILE
VALIDATE $? "coping nginx file"

systemctl restart nginx &>> $LOGS_FILE
VALIDATE $? "start nginx"

