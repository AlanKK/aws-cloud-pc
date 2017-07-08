# VMDK to AMI Converter


## About

This module will upload a specified vmdk file to a specified aws s3 bucket using a specified AWS config.
After upload to s3 is complete, will make the ec2 call to convert the uploaded vmdk file to an ami. Script will
monitor progress of the ami import.

After the initial ami import is complete, this script will copy that ami image to all specified aws regions, with the
specified name. Script monitors all aws cp operations and waits for complete or error.

## Requirements

In order to complete all necessary operations to upload, import and copy images the following system requirements must be
met
- awscli installed and configured: In order to perform aws commands, you must configure ~/.awscli/profile
and ~/.awscli/config as defined in: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
- The specified s3 bucket must already exist in first region chosen for the ami upload
- AWS credentials must have permissions described in: http://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html
- Exported VM must meet AWS pre-reqs: http://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html

This script does its best to validate that you have permissions, but no promises are made

## Installation

It's in the public pypi repository. Simply run:

```
$ pip install amiuploader
```

## Running
You can get a list of all arguments at the runtime help prompt

Example run: (Upload ami to us-west-1 and us-west-2 regions, with the name "dr-test")

```sh
 amiupload -r 'us-west-1' 'us-west-2' -a "aws-admin-it" -b silo-ami-testing -f AMI_DB-Remote.vmdk -n "dr-test"
 
```

All options:

```
amiupload -h
usage: amiupload [-h] -r AWS_REGIONS [AWS_REGIONS ...] -a AWS_PROFILE -b
                 S3_BUCKET -f VMDK_UPLOAD_FILE [-n AMI_NAME] [-d DIRECTORY]

Uploads specified VMDK file to AWS s3 bucket, and converts to AMI

optional arguments:
  -h, --help            show this help message and exit
  -r AWS_REGIONS [AWS_REGIONS ...], --aws_regions AWS_REGIONS [AWS_REGIONS ...]
                        list of AWS regions where uploaded ami should be
                        copied. Available regions: ['us-east-1', 'us-east-2',
                        'us-west-1', 'us-west-2', 'ca-central-1', 'eu-west-1',
                        'eu-central-1', 'eu-west-2', 'ap-northeast-1', 'ap-
                        northeast-2', 'ap-southeast-2', 'ap-south-1', 'sa-
                        east-1'].
  -a AWS_PROFILE, --aws_profile AWS_PROFILE
                        AWS profile name to use for aws cli commands
  -b S3_BUCKET, --s3_bucket S3_BUCKET
                        The aws_bucket of the profile to upload and save vmdk
                        to
  -f VMDK_UPLOAD_FILE, --vmdk_upload_file VMDK_UPLOAD_FILE
                        The file to upload if executing
  -n AMI_NAME, --ami_name AMI_NAME
                        The name to give to the uploaded ami. Defaults to the
                        name of the file
  -d DIRECTORY, --directory DIRECTORY
                        Directory to save temp aws config upload files
```

