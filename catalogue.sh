#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
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
VALIDATE $? "Disabling existing nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling existing nodejs 20"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing nodejs 20"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app  &>> $LOGS_FILE
VALIDATE $? "Creating a app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading catalogue code"

cd /app 
VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping catalogue code"

cd /app 

npm install &>> $LOGS_FILE
VALIDATE $? "Installing npm file"

cp $CURRENT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "Created systemctl service"

systemctl enable catalogue &>> $LOGS_FILE
VALIDATE $? "Created systemctl service"

systemctl start catalogue &>> $LOGS_FILE
VALIDATE $? "Created systemctl service"

cp $CURRENT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo repo file"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "Installing Mongodb"

INDEX=$(mongosh --host $MONGO_DB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGO_DB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"





