#!/bin/bash

# Find the instance ID with the "game" tag
INSTANCE_ID=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.Tags[] | .Key == "game") | .InstanceId' 
)

if [ -z "$INSTANCE_ID" ] ; then
    echo "Can't find instance."
    exit 1
fi

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