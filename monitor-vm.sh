AMI_NAME="Win10_v7"
AMI_DESCRIPTION="Win10_v7"

# Parse input parameters
process_vm_file() {
	IMPORT_TASK_ID=""

	while [[ "$#" -gt 0 ]]; do
	    case $1 in
		-i) IMPORT_TASK_ID="$2"; shift ;;  # Store the file path in the variable
		*) echo "Unknown parameter passed: $1"; exit 1 ;;
	    esac
	    shift
	done


old_status_msg="."
while true; do
    result=$(aws ec2 describe-import-image-tasks --import-task-ids $IMPORT_TASK_ID)
    status=$(echo $result | jq -r .ImportImageTasks[0].Status)
    status_msg=$(echo $result | jq -r .ImportImageTasks[0].StatusMessage)
    
    if [ "$status" == "active" ]; then
        if [ $status_msg == $old_status_msg ]; then
            echo ".\c"
	else
	    echo $status $status_msg "\c"
            old_status_msg=$status_msg
        fi
    elif [ "$status" == "completed" ]; then
        echo "Import image task is completed."
	echo $result | jq
        break
    else
	echo $result | jq
        exit 1
    fi

    sleep 1
done


# Get the AMI ID
AMI_ID=$(aws ec2 describe-import-image-tasks --import-task-ids "$IMPORT_TASK_ID" | jq -r .ImportImageTasks[0].ImageId)

echo "Creating tags"
aws ec2 create-tags --resources "$AMI_ID" --tags Key="game",Value="AMI_NAME"
#aws ec2 enable-fast-launch --image-id $AMI_ID --resource-type snapshot --max-parallel-launches 6

echo "AMI creation complete. AMI ID: $AMI_ID"
