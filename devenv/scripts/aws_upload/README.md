# Creating a CentOS 7 AWS AMI from a local VMWare VMDK
https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html

## Prerequisites
Configure role vmimport in AWS IAM
aws iam create-role --role-name vmimport --assume-role-policy-document "file:///Users/georg/projects/bi/devenv/devenv/scripts/aws_upload/trust-policy.json"

add policy to newly created role
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file:///Users/georg/projects/bi/devenv/devenv/scripts/aws_upload/role-policy.json"

import VMDK from S3 bucket to AMI:
aws ec2 import-image --description "ODS dev env" --disk-containers file:///Users/georg/projects/bi/devenv/devenv/scripts/aws_upload/containers.json

check status of vmdk import service
