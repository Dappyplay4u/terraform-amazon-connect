###############################################################################
# Kinesis Complete Example — Variables
###############################################################################

variable "aws_region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
}

variable "project_name" {
  description = "Full project name used in name_prefix (e.g. retail-connect)"
  type        = string
}

variable "environment" {
  description = "Deployment environment: prod | qa | test"
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key ID for Kinesis stream encryption"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for Firehose IAM policy"
  type        = string
}

variable "ctr_s3_bucket_arn" {
  description = "S3 bucket ARN for CTR Firehose delivery"
  type        = string
  default     = ""
}

variable "alarm_sns_topic_arns" {
  description = "SNS topic ARNs for CloudWatch alarm notifications"
  type        = list(string)
  default     = []
}

# ── Required Tags ──────────────────────────────────────────────────────────────

variable "business_application_id"   { type = string }
variable "cost_center"               { type = string }
variable "created_by"                { type = string }
variable "technical_support_by"      { type = string }
variable "application_group"         { type = string }
variable "technical_environment"     { type = string }
variable "security_data_application" { type = string }
variable "business_application_code" { type = string }
