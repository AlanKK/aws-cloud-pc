#!/bin/bash
set -x
Bucket="ec2-amd-windows-drivers"
LocalPath="~/Downloads/CloudGaming/"

aws s3 cp --recursive s3://ec2-amd-windows-drivers/latest/ .
#aws s3 cp --recursive s3://ec2-windows-nvidia-drivers/latest/ .

exit

# Originally ...

# $KeyPrefix = "latest/AMD_GPU_WINDOWS10"

# Install-AWSToolsModule AWS.Tools.S3 -CleanUp

# $Bucket = "ec2-amd-windows-drivers"
# $LocalPath = "$home\Desktop\AMD"
# $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
# foreach ($Object in $Objects) {
# $LocalFileName = $Object.Key
# if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
#     $LocalFilePath = Join-Path $LocalPath $LocalFileName
#     Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
#     }
# } 

