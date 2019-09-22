#!/bin/bash

export TF_VAR_s3_bucket_name=$1
export TF_VAR_sts_assume_role_arn=$2

terraform init

terraform plan

terraform apply
