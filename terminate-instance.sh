#!/bin/bash

# Find the instance ID with the "game" tag
INSTANCE_ID=$(aws ec2 describe-instances --filters Name=tag:game --query 'Reservations[].Instances[].InstanceId' --output text)

# Terminate the EC2 instance
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Check the status of the instance every 5 seconds
while true; do
  STATUS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].State.Name' --output text)
  echo "Instance status: $STATUS"
  if [ "$STATUS" == "terminated" ]; then
    break
  fi
  sleep 5
done

# Wait for user input before exiting
echo -en "\007" # Beep
read -p "Instance terminated. Press Enter to exit..."