
## About

Upload a specified VM file to a specified aws s3 bucket using a specified AWS config.
After upload to s3 is complete, will make the ec2 call to convert the uploaded VM file to an AMI. Script will
monitor progress of the AMI import.

Upload VM, create AMI, Launch intance

## Scripts


launch-instance.sh will take everything with "game" and expects the AMI to have that tag
### vm2ami.sh
Edit the script and configure the following:

```
S3_BUCKET_NAME="your-bucket-name"
REGION="us-east-1"
AMI_NAME="Win10_v1"
AMI_DESCRIPTION="Win10_Gaming"
```
Usage:
```
./vm2ami.sh --vm-file <path to your .vhd file>
```

### get-gpu-driver.sh
### launch-instance.sh


### terminate-instance.sh

Usage:
```
./terminate-instanch.sh
```

Finds the instance with the tag "game" and terminate it.


## Requirements

- jq - https://jqlang.github.io/jq/download/
- awscli installed and configured
- The specified s3 bucket must already exist in first region chosen for the ami upload
- AWS credentials must have permissions described in: http://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html.  
- Exported VM must meet AWS pre-reqs: http://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html
- You can use Virtualbox on Mac or Windows to create a VM with with the disk as a VHD