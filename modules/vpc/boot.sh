#!/bin/bash
#
# Usage: AWS_S3_BUCKET=backet.example.com bash boot.sh
#

AWS_S3_KEY=.terraform/network/terraform.tfstate
source .env

terraform init \
    -backend-config "bucket=$AWS_S3_BUCKET" \
    -backend-config "key=$AWS_S3_KEY"

terraform plan

terraform apply
