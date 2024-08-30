#!/bin/bash

# Find the launch template and AMI with the "game" tag
TEMPLATES=$(aws ec2 describe-launch-templates)
TEMPLATE_ID=$(jq -r '.LaunchTemplates[] | select(.Tags // [] | .[] | .Key == "game") | .LaunchTemplateId' <<< $TEMPLATES)
TEMPLATE_NAME=$(jq -r '.LaunchTemplates[] | select(.Tags // [] | .[] | .Key == "game") | .LaunchTemplateName' <<< $TEMPLATES)
echo "Launching instance:"
echo "  template: $TEMPLATE_NAME $TEMPLATE_ID"

AMIS=$(aws ec2 describe-images --owners self)
AMI_ID=$(jq -r '.Images[] | select(.Tags // [] | .[] | .Key == "game") | .ImageId' <<< $AMIS)
AMI_NAME=$(jq -r '.Images[] | select(.Tags // [] | .[] | .Key == "game") | .Name' <<< $AMIS)
echo "       ami: $AMI_NAME $AMI_ID"

if [ -z "$TEMPLATE_ID" ] || [ -z "$AMI_ID" ] ; then
    echo "Can't find data. Instance not launched."
    exit 1
fi

# Launch the EC2 instance using the launch template and AMI
INSTANCE_ID=$(aws ec2 run-instances --launch-template LaunchTemplateId=$TEMPLATE_ID --image-id $AMI_ID --query 'Instances[].InstanceId' --output text)
echo "Instance ID: $INSTANCE_ID"

# Check the status of the instance every 5 seconds
while true; do
  status=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID| jq -r '.InstanceStatuses[] | select(.InstanceStatus.Details[0].Status == "passed" and .SystemStatus.Details[0].Status == "passed") | "done"')
  if [ "$status" == "done" ]; then
    echo "Launch completed!!!"
    break
  else
    echo "Waiting for instance to pass status checks..."
  fi
  sleep 5
done

# Print the public IP address
IP_ADDRESS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].PublicIpAddress' --output text)
echo "Public IP address: $IP_ADDRESS"

# Wait for user input before exiting
read -p "Press Enter to exit..."
