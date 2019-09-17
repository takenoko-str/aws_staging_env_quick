#!/bin/bash

terraform init \
    -backend-config "bucket=$AWS_S3_BUCKET" \
    -backend-config "key=$AWS_S3_KEY"
