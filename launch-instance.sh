#!/bin/bash

# Variables
#AMI_ID="ami-02378e72f1e6b65e0"
LAUNCH_TEMPLATE_NAME="Win10-Gaming"
INSTANCE_TYPE="g4ad.xlarge"
INSTANCE_COUNT=1
TAG_KEY="Name"
TAG_VALUE="Win10_v12"
TAG2_KEY="game"
TAG2_VALUE="\"\""

set -e

while [[ "$#" -gt 0 ]]; do
    case $1 in
	--ami-id) AMI_ID="$2"; shift ;;  # Store the file path in the variable
	*) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Launch EC2 Instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE_NAME" \
    --instance-type $INSTANCE_TYPE \
    --count $INSTANCE_COUNT \
    --tag-specifications "ResourceType=instance,Tags=[{Key="$TAG_KEY",Value="$TAG_VALUE"},{Key="$TAG2_KEY",Value=$TAG2_VALUE}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

# Check if the instance was created successfully
if [ $? -eq 0 ]; then
    echo "EC2 instance $INSTANCE_ID launched successfully."
fi
