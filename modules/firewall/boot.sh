#!/bin/bash

export TF_VAR_s3_bucket_name=$AWS_S3_BUCKET
#export TF_VAR_sts_assume_role_arn=
export TF_VAR_vpc_id=vpc-0cdd9cc805b38a4d9

terraform init

terraform plan

terraform apply
