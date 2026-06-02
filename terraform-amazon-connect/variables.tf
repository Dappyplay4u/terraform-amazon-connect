###############################################################################
# Core environment variables
###############################################################################

variable "project_name" {
  description = "Project name used as a prefix on every resource (e.g. acme-cc)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project_name))
    error_message = "project_name must be 3-20 chars, lowercase alphanumeric and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region where everything is deployed."
  type        = string
  default     = "us-east-1"
}

variable "cost_center" {
  description = "Cost center tag value."
  type        = string
  default     = "contact-center"
}

###############################################################################
# Amazon Connect instance
###############################################################################

variable "instance_alias" {
  description = "Globally unique alias for the Connect instance."
  type        = string
}

variable "identity_management_type" {
  description = "How users authenticate. CONNECT_MANAGED | SAML | EXISTING_DIRECTORY."
  type        = string
  default     = "CONNECT_MANAGED"
}

variable "inbound_calls_enabled" {
  description = "Allow inbound calls."
  type        = bool
  default     = true
}

variable "outbound_calls_enabled" {
  description = "Allow outbound calls."
  type        = bool
  default     = true
}

variable "enable_contact_lens" {
  description = "Enable Contact Lens analytics."
  type        = bool
  default     = true
}

variable "enable_auto_resolve_best_voices" {
  description = "Auto-resolve best Polly voice per language."
  type        = bool
  default     = true
}

variable "enable_contactflow_logs" {
  description = "Enable contact flow logs to CloudWatch."
  type        = bool
  default     = true
}

variable "enable_call_recording" {
  description = "Record calls to S3."
  type        = bool
  default     = true
}

###############################################################################
# Queues — list of queues to create
###############################################################################

variable "queues" {
  description = "Map of queues to create. Key is short logical name."
  type = map(object({
    description           = string
    hours_of_operation    = string # ref to hours_of_operation key
    max_contacts          = optional(number)
    outbound_caller_id_number = optional(string)
    outbound_caller_id_name   = optional(string)
    quick_connect_keys    = optional(list(string), [])
  }))
}

###############################################################################
# Routing profiles
###############################################################################

variable "routing_profiles" {
  description = "Map of routing profiles."
  type = map(object({
    description               = string
    default_outbound_queue    = string # key into var.queues
    media_concurrencies       = list(object({
      channel     = string # VOICE | CHAT | TASK
      concurrency = number
    }))
    queue_configs = list(object({
      queue_key = string # key into var.queues
      channel   = string
      priority  = number
      delay     = number
    }))
  }))
}

###############################################################################
# Hours of operation
###############################################################################

variable "hours_of_operation" {
  description = "Map of hours-of-operation definitions."
  type = map(object({
    description = string
    time_zone   = string
    config = list(object({
      day         = string # MONDAY..SUNDAY
      start_hours = number
      start_mins  = number
      end_hours   = number
      end_mins    = number
    }))
  }))
}

###############################################################################
# Contact flows
###############################################################################

variable "contact_flows" {
  description = "Map of contact flows. Content is loaded from contact-flow-content/<filename>."
  type = map(object({
    description     = string
    type            = string # CONTACT_FLOW | CUSTOMER_QUEUE | CUSTOMER_HOLD | CUSTOMER_WHISPER | AGENT_WHISPER | OUTBOUND_WHISPER | AGENT_TRANSFER | QUEUE_TRANSFER
    content_file    = string # filename under contact-flow-content/
  }))
}

###############################################################################
# Lambda functions
###############################################################################

variable "lambda_functions" {
  description = "Map of Lambda functions to deploy."
  type = map(object({
    description   = string
    handler       = string
    runtime       = string
    timeout       = optional(number, 15)
    memory_size   = optional(number, 256)
    source_dir    = string # path under lambda-source/
    environment   = optional(map(string), {})
    dynamodb_access = optional(list(string), []) # list of dynamodb table keys
    associate_with_connect = optional(bool, true)
  }))
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log retention for Lambdas."
  type        = number
  default     = 14
}

###############################################################################
# DynamoDB tables
###############################################################################

variable "dynamodb_tables" {
  description = "Map of DynamoDB tables to create."
  type = map(object({
    hash_key  = string
    range_key = optional(string)
    attributes = list(object({
      name = string
      type = string # S | N | B
    }))
    global_secondary_indexes = optional(list(object({
      name            = string
      hash_key        = string
      range_key       = optional(string)
      projection_type = string
    })), [])
    ttl_attribute = optional(string)
    stream_enabled = optional(bool, false)
    point_in_time_recovery = optional(bool, false)
  }))
}

variable "dynamodb_billing_mode" {
  description = "PAY_PER_REQUEST | PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

###############################################################################
# S3 storage
###############################################################################

variable "enable_s3_versioning" {
  description = "Versioning on all S3 buckets."
  type        = bool
  default     = true
}

variable "s3_lifecycle_recording_days" {
  description = "Days to retain call recordings before transitioning to Glacier."
  type        = number
  default     = 90
}

variable "s3_lifecycle_report_days" {
  description = "Days to retain reports."
  type        = number
  default     = 365
}

###############################################################################
# KMS
###############################################################################

variable "use_customer_managed_kms" {
  description = "Use customer-managed KMS keys for encryption (vs AWS-managed)."
  type        = bool
  default     = false
}

###############################################################################
# Quick connects
###############################################################################

variable "quick_connects" {
  description = "Map of quick connect destinations."
  type = map(object({
    description     = string
    type            = string # USER | QUEUE | PHONE_NUMBER
    phone_number    = optional(string)
    queue_key       = optional(string)
    contact_flow_key = optional(string)
  }))
  default = {}
}
