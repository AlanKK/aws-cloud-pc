
## About



## Scripts

### `vm2ami.sh`
Upload and convert a local .vhd VM disk to an S3 bucket and convert to an AMI

Upload a VM file to an aws s3 bucket.  After upload to s3 is complete, will convert the uploaded VM file to an AMI. Script will monitor progress of the AMI import.  Prompt y/n to launch the instance.

Usage:
`./vm2ami.sh --vm-file <path to your .vhd file>`

Rename config-sample.txt to config.txt and set up for your needs:
```
S3_BUCKET_NAME="your-bucket-name"
REGION="us-east-1"
AMI_NAME="Win10_v1"
AMI_DESCRIPTION="Win10_Gaming"
```


Requirements:
- The specified s3 bucket must already exist in first region chosen for the ami upload
- AWS credentials must have permissions described in: http://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html
- Exported VM must meet AWS pre-reqs: http://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html
- You can use Virtualbox on Mac or Windows to create a VM with with the disk as a VHD

### ```launch-instance.sh```

Requires an AMI and a launch template tagged with "game".  Launch an ec2 instace with them and change cloudflare DNS entry to the public IP of the instance.  Monitor the progress.

### ```save-instance-to-ami```

Take a running or stopped ec2 instance, shut it down, and create an AMI.  When done, terminate instance.  Remove the "game" tag from existing AMIs and add it to the new one. This will leave us ready to start up again where we left off, like a reboot rather than a reset.

### ```terminate-instance.sh```

Usage:  ```./terminate-instance.sh```

Finds the instance with the tag "game" and terminate it.  Will not delete the volume associated with the instance.  The volume should be set to be deleted when the instance is terminated in the launch template.

### ```get-gpu-driver.sh```

Simply `aws s3 cp --recursive s3://ec2-amd-windows-drivers/latest/ .`

Change it to `ec2-windows-nvidia-drivers` for nVidia drivers.

See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-GRID-driver

## ```General Requirements```

- jq - download from https://jqlang.github.io/jq/download/

- awscli installed and configured.  Run `aws sts get-caller-identity` to make sure it works
