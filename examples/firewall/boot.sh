#!/bin/bash

export TF_VAR_s3_bucket_name=$1

terraform init

terraform plan

terraform apply