###############################################################################
# Connect Instance Module — Variables
###############################################################################

# ── Provider ──────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
  default     = "us-east-1"
}

# ── Naming ────────────────────────────────────────────────────────────────────

variable "project_spec" {
  description = "Short project specifier for the instance alias segment (e.g. retail)"
  type        = string
}

variable "project_name" {
  description = "Full project name used in name_prefix (e.g. retail-connect)"
  type        = string
}

variable "environment" {
  description = "Deployment environment: prod | qa | test"
  type        = string
  validation {
    condition     = contains(["prod", "qa", "test"], var.environment)
    error_message = "environment must be prod, qa, or test."
  }
}

variable "aws_region_alias" {
  description = "Short region alias for instance alias (e.g. ue1 = us-east-1, uw1 = us-west-1)"
  type        = string
}

# ── Connect Features ──────────────────────────────────────────────────────────

variable "auto_resolve_best_voices_enabled" {
  description = "Auto-resolve best voices for outbound contacts"
  type        = bool
  default     = true
}

variable "media_stream_retention_hours" {
  description = "Kinesis Video Stream retention for media streams in hours"
  type        = number
  default     = 24
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days for contact flow logs"
  type        = number
  default     = 90
}

# ── Pre-existing resource overrides ──────────────────────────────────────────
# Leave as "" to let this module create KMS / S3 / Kinesis automatically.
# Populate to bring-your-own pre-created resources.

variable "existing_kms_s3_arn" {
  description = "Existing KMS key ARN for S3 (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "existing_kms_kinesis_arn" {
  description = "Existing KMS key ARN for Kinesis (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "existing_kms_connect_arn" {
  description = "Existing KMS key ARN for Connect CW logs (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "existing_s3_call_recordings_id" {
  description = "Existing S3 bucket ID for call recordings (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "existing_s3_scheduled_reports_id" {
  description = "Existing S3 bucket ID for scheduled reports (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "existing_s3_chat_transcripts_id" {
  description = "Existing S3 bucket ID for chat transcripts (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "existing_kinesis_ctr_arn" {
  description = "Existing Kinesis stream ARN for CTR (leave empty to auto-create)"
  type        = string
  default     = ""
}

# ── KMS child module pass-throughs (used when auto-creating) ─────────────────

variable "key_admin_arns" {
  description = "IAM ARNs granted KMS key admin permissions (used when auto-creating KMS keys)"
  type        = list(string)
  default     = []
}

# ── Kinesis child module pass-throughs ────────────────────────────────────────

variable "kinesis_stream_mode" {
  description = "Kinesis stream mode: ON_DEMAND | PROVISIONED"
  type        = string
  default     = "ON_DEMAND"
}

variable "kinesis_retention_hours" {
  description = "Kinesis stream retention hours"
  type        = number
  default     = 24
}

variable "enable_firehose_ctr" {
  description = "Deploy Firehose CTR → S3 (used when auto-creating Kinesis)"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arns" {
  description = "SNS topic ARNs for Kinesis CloudWatch alarms"
  type        = list(string)
  default     = []
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Required and optional tags — validated for all 8 mandatory keys"
  type        = map(string)
  default     = {}

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
