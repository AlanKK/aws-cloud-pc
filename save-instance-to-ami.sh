#!/bin/bash

INSTANCE_ID=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.Tags[] | .Key == "game") | .InstanceId')
if [ -z "$INSTANCE_ID" ]; then
  echo "Error: No EC2 instance found with tag:game"
  exit 1
fi

echo "Stopping the EC2 instance..."
if ! aws ec2 stop-instances --instance-ids $INSTANCE_ID; then
  echo "Error: Failed to stop EC2 instance $INSTANCE_ID"
  exit 1
fi

echo "Waiting for instance to stop..."
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID

echo "Remove the game tag from other AMIs"
OLD_AMI_ID=$(aws ec2 describe-images --owners self | jq -r '.Images[] | select((.Tags // [])[] | .Key == "game") | .ImageId')
if [ -z "$OLD_AMI_ID" ]; then
    echo "Warning: Failed to get AMI ID from other AMIs"
fi

DATE=$(date +"%Y-%m-%d_%H_%M")

echo "Creating an AMI from the stopped instance..."
AMI_ID=$(aws ec2 create-image --instance-id $INSTANCE_ID --name "Win10_$DATE" --query "ImageId" --output text)
if [ -z "$AMI_ID" ]; then
  echo "Error: Failed to create AMI from instance $INSTANCE_ID"
  exit 1
fi

echo "Deleting tags from old ami..."
result=$(aws ec2 delete-tags --resources $OLD_AMI_ID --tags "Key=game")
if [ -n "$result" ]; then
  echo "Warning: Failed to remove tag from $OLD_AMI_ID"
fi

if ! aws ec2 describe-images --owners self | jq -r '.Images[] | select((.Tags // [])[] | .Key == "game") | .ImageId'; then
  echo "Error: Failed to remove game tag from other AMIs"
  exit 1
fi

echo "Waiting for AMI creation to complete..."
aws ec2 wait image-available  --image-ids $AMI_ID

echo "Tag the new AMI with game"
if ! aws ec2 create-tags --resources $AMI_ID --tags "Key=game, Value=''"; then
  echo "Error: Failed to tag AMI $AMI_ID with game"
  exit 1
fi

echo "EC2 instance stopped and AMI created:"
echo "AMI ID: $AMI_ID"
echo "Instance State: $(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].State.Name" --output text)"

read -p "Press Enter to continue and terminate the EC2 instance... "

echo "Terminating the EC2 instance..."
if ! aws ec2 terminate-instances  --instance-ids $INSTANCE_ID; then
  echo "Error: Failed to terminate EC2 instance $INSTANCE_ID"
  exit 1
fi
