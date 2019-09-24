#!/bin/bash

export TF_VAR_s3_bucket_name=$AWS_S3_BUCKET
#export TF_VAR_sts_assume_role_arn=

terraform init

terraform plan

terraform apply
