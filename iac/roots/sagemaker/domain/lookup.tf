// Copyright 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

data "aws_ssm_parameter" "smus_domain_provisioning_role_arn" {

  name = "/${var.APP}/${var.ENV}/smus_domain_provisioning_role_arn"
}

data "aws_ssm_parameter" "smus_domain_execution_role_arn" {

  name = "/${var.APP}/${var.ENV}/smus_domain_execution_role_arn"
}

data "aws_ssm_parameter" "smus_domain_service_role_arn" {

  name = "/${var.APP}/${var.ENV}/smus_domain_service_role_arn"
}

data "aws_ssm_parameter" "smus_projects_bucket_s3_url" {

  name = "/${var.APP}/${var.ENV}/smus_projects_bucket_s3_url"
}

data "aws_ssm_parameter" "smus_domain_vpc_id" {

  name = "/${var.APP}/${var.ENV}/smus_domain_vpc_id"
}

data "aws_ssm_parameter" "smus_domain_private_subnet_ids" {

  name = "/${var.APP}/${var.ENV}/smus_domain_private_subnet_ids"
}

data "aws_ssm_parameter" "smus_domain_availability_zone_names" {

  name = "/${var.APP}/${var.ENV}/smus_domain_availability_zone_names"
}

# Get the JSON string from SSM Parameter Store
data "aws_ssm_parameter" "user_mappings" {
  name = "/${var.APP}/${var.ENV}/identity-center/users"
}

locals {
  SMUS_DOMAIN_PROVISIONING_ROLE_ARN   = data.aws_ssm_parameter.smus_domain_provisioning_role_arn.value
  SMUS_DOMAIN_EXECUTION_ROLE_ARN      = data.aws_ssm_parameter.smus_domain_execution_role_arn.value
  SMUS_DOMAIN_SERVICE_ROLE_ARN        = data.aws_ssm_parameter.smus_domain_service_role_arn.value
  SMUS_PROJECTS_BUCKET_S3_URL         = data.aws_ssm_parameter.smus_projects_bucket_s3_url.value
  SMUS_DOMAIN_VPC_ID                  = data.aws_ssm_parameter.smus_domain_vpc_id.value
  SMUS_DOMAIN_PRIVATE_SUBNET_IDS      = data.aws_ssm_parameter.smus_domain_private_subnet_ids.value
  SMUS_DOMAIN_AVAILABILITY_ZONE_NAMES = data.aws_ssm_parameter.smus_domain_availability_zone_names.value
  SMUS_DOMAIN_USER_MAPPINGS           = data.aws_ssm_parameter.user_mappings.value
}
