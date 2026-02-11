#!/bin/bash

for instance in "$@"
do
    echo "Terminating instance: $instance"

    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)

    if [ -z "$INSTANCE_ID" ]; then
        echo "No running instance found with name: $instance"
        continue
    fi

    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"

    echo "Waiting for $instance to stop..."
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"

    echo "$instance terminated successfully"
    
done
