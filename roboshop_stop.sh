#!/bin/bash

for instance in "$@"
do
    echo "Stopping instance: $instance"

    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text)

    if [ -z "$INSTANCE_ID" ]; then
        echo "No running instance found with name: $instance"
        continue
    fi

    aws ec2 stop-instances --instance-ids "$INSTANCE_ID"

    echo "Waiting for $instance to stop..."
    aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"

    echo "$instance stopped successfully"
    
done
