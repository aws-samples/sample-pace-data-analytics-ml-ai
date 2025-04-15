// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {
  backend "s3" {
    bucket         = "###TF_S3_BACKEND_NAME###-###AWS_ACCOUNT_ID###-###AWS_DEFAULT_REGION###"
    dynamodb_table = "###TF_S3_BACKEND_NAME###-lock"
    region         = "###AWS_PRIMARY_REGION###"
    key            = "###ENV_NAME###/idc-org/terraform.tfstate"
    encrypt        = true
  }
}
