#!/bin/bash

set -e
source config.txt

# Parse input parameters
process_vm_file() {
	VM_FILE=""

	while [[ "$#" -gt 0 ]]; do
	    case $1 in
		--vm-file) VM_FILE="$2"; shift ;;  # Store the file path in the variable
		*) echo "Unknown parameter passed: $1"; exit 1 ;;
	    esac
	    shift
	done

	# Check if VM_FILE is set
	if [ -z "$VM_FILE" ]; then
	    echo "Error: --vm-file parameter is required."
	    exit 1
	fi

	filename=$(basename "$VM_FILE")
	extension="${filename##*.}"
	if [[ "$extension" != "raw" && "$extension" != "vmdk" && "$extension" != "ova" && "$extension" != "vhd" ]]; then
	    echo "Error: Invalid file extension. Only .vmdk, .ova, .raw, or .vhd are allowed."
	    exit 1
	fi

	if [ ! -f "$VM_FILE" ]; then
	    echo "Error: The file '$VM_FILE' does not exist."
	    exit 1
	fi
}

# --------- Main ----------------
process_vm_file "$@"

echo "Uploading $VM_FILE to s3://$S3_BUCKET_NAME"
aws s3 cp "$VM_FILE" "s3://$S3_BUCKET_NAME/"

echo "Creating iam role and setting permissions"
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "vmie.amazonaws.com" },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:Externalid": "vmimport"
        }
      }
    }
  ]
}
EOF
aws iam create-role --role-name vmimport --assume-role-policy-document file://trust-policy.json

echo "Set up permissions for S3 access"
cat <<EOF > role-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::$S3_BUCKET_NAME"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::$S3_BUCKET_NAME/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:ModifySnapshotAttribute",
        "ec2:CopySnapshot",
        "ec2:RegisterImage",
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://role-policy.json

echo "Creating import task"
VM_FILENAME=$(basename "$VM_FILE")
cat <<EOF > containers.json
[
  {
    "Description": "$AMI_DESCRIPTION",
    "Format": "$extension",
    "UserBucket": {
      "S3Bucket": "$S3_BUCKET_NAME",
      "S3Key": "$VM_FILENAME"
    }
  }
]
EOF

IMPORT_TASK_ID=$(aws ec2 import-image --description "$AMI_DESCRIPTION" --disk-containers file://containers.json --query 'ImportTaskId' --output text)

# Wait for import task to complete
echo "Importing $VM_FILE to ec2, ID $IMPORT_TASK_ID ..."

old_status_msg="."
while true; do
    result=$(aws ec2 describe-import-image-tasks --import-task-ids $IMPORT_TASK_ID)
    status=$(jq -r .ImportImageTasks[0].Status <<< $result)
    status_msg=$(jq -r .ImportImageTasks[0].StatusMessage <<< $result)
    
    if [ "$status" == "active" ]; then
        if [ -n "$status_msg" ] && [ "$status_msg" == "$old_status_msg" ]; then
            echo -n "."
	else
	    echo -n $status $status_msg " "
            old_status_msg=$status_msg
	fi
    elif [ "$status" == "completed" ]; then
	if [ $status_msg=="" ]; then
            echo "Import image task is completed!!!"
	    echo $result | jq
            break
	fi
    else
	echo $result | jq
        exit 1
    fi

    sleep 10
done

# Get the AMI ID
AMI_ID=$(aws ec2 describe-import-image-tasks --import-task-ids "$IMPORT_TASK_ID" | jq -r .ImportImageTasks[0].ImageId)

echo "Creating tags"
aws ec2 create-tags --resources "$AMI_ID" --tags Key="game",Value="AMI_NAME"

echo "AMI creation complete. AMI ID: $AMI_ID"

read -p "Launch Instance? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    ./launch-instance.sh --ami-id "$AMI_NAME"
fi

