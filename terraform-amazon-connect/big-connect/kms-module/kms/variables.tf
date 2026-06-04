###############################################################################
# KMS Module — Variables
###############################################################################

# ── Provider ──────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy into (e.g. us-east-1)"
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

# ── KMS Key Configuration ─────────────────────────────────────────────────────

variable "kms_keys" {
  description = <<-EOT
    Map of KMS keys to create.
    Key name = logical purpose (e.g. "s3", "kinesis", "connect").
    - policy             : optional custom JSON key policy (null = use generated default)
    - service_principals : AWS service principals allowed to use the key
                           (empty list = module defaults per key name)
    - deletion_window    : pending-deletion window in days (7–30)
  EOT
  type = map(object({
    policy             = optional(string, null)
    service_principals = optional(list(string), [])
    deletion_window    = optional(number, 30)
  }))

  default = {
    s3      = {}
    kinesis = {}
    connect = {}
  }
}

variable "key_admin_arns" {
  description = "IAM principal ARNs granted key administration permissions"
  type        = list(string)
  default     = []
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Required and optional resource tags applied to all KMS resources"
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
