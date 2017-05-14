#!/usr/bin/python
import argparse
import AWSUtilities
from OvfExporter import OvfExporter
import tempfile
import os
import sys


def parse_args():
    """
        Required args
        - file to upload
        - aws profile (must be pre-configured)
        - aws_regions
        - AMI save name
    """
    parser = argparse.ArgumentParser(description="Uploads specified VMDK file to AWS s3 bucket, and converts to AMI")
    parser.add_argument('-r', '--aws_regions', type=str, nargs='+', required=True,
                        help='Comma delimited list of AWS regions where uploaded ami should be copied. Available'
                             ' regions: {}.'.format(AWSUtilities.aws_regions))
    parser.add_argument('-a', '--aws_profile', type=str, required=True, help='AWS profile name to use for aws cli commands')
    parser.add_argument('-b', '--s3_bucket', type=str, required=True,
                        help='The aws_bucket of the profile to upload and save vmdk to')
    parser.add_argument('-f', '--vmdk_upload_file', type=str, required=True,
                        help="The file to upload if executing ")
    parser.add_argument('-n', '--ami_name', type=str, required=False, help='The name to give to the uploaded ami. '
                                                                           'Defaults to the name of the file')
    parser.add_argument('-d', '--directory', type=str, default=tempfile.mkdtemp(),
                        help='Directory to save temp aws config upload files')
    args = parser.parse_args()

    if not os.path.isfile(args.vmdk_upload_file):
        print "{} Does not exist.".format(args.directory)
        sys.exit(5)

    if not args.ami_name:
        args.ami_name = os.path.basename(args.vmdk_upload_file)

    print "Regions came in as: {}".format(args.regions)

    return args


def validate_args(args):
    # TODO: validate that aws login works, s3 bucket exists, user has permissions required, vcenter authentication works, and vm exits
    # print size of vm to be dl, if dl dir exists, check that file to uplad is a vmdk
    pass


def convert(args):
    aws_importer = AWSUtilities.AWSUtils(args.directory, args.profile, args.aws_bucket,
                                         args.regions, args.ami_name, args.vmdk_upload_file)
    aws_importer.import_vmdk()  # TODO: change api calls to subprocess calls.

if __name__ == "__main__":
    args = parse_args()
    convert(args)
