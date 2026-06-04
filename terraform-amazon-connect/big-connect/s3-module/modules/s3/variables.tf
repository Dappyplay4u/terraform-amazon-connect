###############################################################################
# S3 Module — Variables
###############################################################################

# ── Provider ──────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
  default     = "us-east-1"
}

# ── Naming ────────────────────────────────────────────────────────────────────

variable "project_name" {
  description = "Full project name used in name_prefix (e.g. retail-connect)"
  type        = string
}

variable "environment" {
  description = "Deployment environment: prod | qa | test"
  type        = string

  validation {
    condition     = contains(["prod", "qa", "test"], var.environment)
    error_message = "environment must be one of: prod, qa, test."
  }
}

# ── Encryption ────────────────────────────────────────────────────────────────

variable "kms_key_arn" {
  description = "KMS key ARN used for S3 server-side encryption (from kms module output: s3_key_arn)"
  type        = string
}

# ── Bucket Behaviour ──────────────────────────────────────────────────────────

variable "force_destroy" {
  description = "Allow Terraform to destroy non-empty buckets. Set true only in non-prod."
  type        = bool
  default     = false
}

variable "enable_access_logging" {
  description = "Create a dedicated access-log bucket and enable logging on all data buckets"
  type        = bool
  default     = true
}

# ── Lifecycle ─────────────────────────────────────────────────────────────────

variable "lifecycle_ia_transition_days" {
  description = "Days after object creation before transitioning to STANDARD_IA"
  type        = number
  default     = 90
}

variable "lifecycle_glacier_transition_days" {
  description = "Days after object creation before transitioning to GLACIER"
  type        = number
  default     = 365
}

variable "lifecycle_expiration_days" {
  description = "Days after object creation before permanent expiration (0 = no expiry)"
  type        = number
  default     = 2555 # ~7 years
}

variable "noncurrent_version_expiration_days" {
  description = "Days before non-current object versions are expired"
  type        = number
  default     = 90
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Required and optional tags applied to all S3 resources"
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
    error_message = <<-EOT
      tags must include all 8 required keys:
      business_application_id, cost_center, created_by, technical_support_by,
      application_group, technical_environment, security_data_application,
      business_application_code.
    EOT
  }
}
