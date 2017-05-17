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

Ensure you have the local silo repository in your .pip config and:

```
$ pip install amiuploader
```

## Running
You can get a list of all arguments at the runtime help prompt

Example run: (Upload ami to us-west-1 and us-west-2 regions, with the name "dr-test")

```sh
$ amiupload -r 'us-west-1' 'us-west-2' -a "aws-admin-it" -b silo-ami-testing -f AMI_DB-Remote.vmdk -n "dr-test"
```

