###############################################################################
# Kinesis Module — Variables
###############################################################################

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" { type = string }

variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "qa", "test"], var.environment)
    error_message = "environment must be prod, qa, or test."
  }
}

variable "kms_key_id" {
  description = "KMS Key ID for Kinesis stream encryption (from kms module: kinesis_key_id)"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for Firehose IAM policy (from kms module: kinesis_key_arn)"
  type        = string
}

variable "stream_mode" {
  description = "ON_DEMAND or PROVISIONED"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "PROVISIONED"], var.stream_mode)
    error_message = "stream_mode must be ON_DEMAND or PROVISIONED."
  }
}

variable "shard_count" {
  description = "Shard count — only used when stream_mode = PROVISIONED"
  type        = number
  default     = 1
}

variable "retention_period_hours" {
  description = "Stream data retention in hours (24–8760)"
  type        = number
  default     = 24
  validation {
    condition     = var.retention_period_hours >= 24 && var.retention_period_hours <= 8760
    error_message = "retention_period_hours must be 24–8760."
  }
}

# ── Firehose CTR → S3 ─────────────────────────────────────────────────────────

variable "enable_firehose_ctr" {
  description = "Deploy Kinesis Firehose to deliver CTR records to S3"
  type        = bool
  default     = true
}

variable "ctr_s3_bucket_arn" {
  description = "S3 bucket ARN for CTR Firehose delivery (from s3 module: call_recordings_bucket_arn)"
  type        = string
  default     = ""
}

variable "firehose_buffering_size_mb" {
  type    = number
  default = 5
}

variable "firehose_buffering_interval_seconds" {
  type    = number
  default = 300
}

# ── CloudWatch Alarms ─────────────────────────────────────────────────────────

variable "enable_cloudwatch_alarms" {
  type    = bool
  default = true
}

variable "iterator_age_alarm_threshold_ms" {
  type    = number
  default = 60000
}

variable "alarm_sns_topic_arns" {
  type    = list(string)
  default = []
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  type    = map(string)
  default = {}

  validation {
    condition = alltrue([
      contains(keys(var.tags), "business_application_id"),
      contains(keys(var.tags), "cost_center"),
      contains(keys(var.tags), "created_by"),
      contains(keys(var.tags), "technical_support_by"),
      contains(keys(var.tags), "application_group"),
      contains(keys(var.tags), "technical_environment"),
      contains(keys(var.tags), "security_data_application"),
      contains(keys(var.tags), "business_application_code"),
    ])
    error_message = "tags must include all 8 required tag keys."
  }
}
