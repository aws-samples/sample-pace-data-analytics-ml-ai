// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

terraform {

  backend "s3" {

    bucket       = "###TF_S3_BACKEND_NAME###-###AWS_ACCOUNT_ID###-###AWS_PRIMARY_REGION###"
    key          = "###ENV_NAME###/domain/terraform.tfstate"
    use_lockfile = true
    region       = "###AWS_PRIMARY_REGION###"
    encrypt      = true
  }
}
