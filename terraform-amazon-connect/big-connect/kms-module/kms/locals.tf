###############################################################################
# KMS Module — Locals
###############################################################################

locals {
  # Resolved name prefix used for all resource names and alias paths
  name_prefix = "${var.project_name}-${var.environment}"

  # Account and region pulled from data sources (no hardcoding)
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  # Default service principals per key purpose if none provided by caller
  default_service_principals = {
    s3      = ["s3.amazonaws.com", "connect.amazonaws.com"]
    kinesis = ["kinesis.amazonaws.com", "firehose.amazonaws.com"]
    connect = ["connect.amazonaws.com", "logs.${local.region}.amazonaws.com"]
  }

  # Merge caller-supplied service principals with defaults
  resolved_keys = {
    for k, v in var.kms_keys :
    k => merge(v, {
      service_principals = length(v.service_principals) > 0 ? v.service_principals : lookup(local.default_service_principals, k, [])
    })
  }

  # Common tags merged with mandatory tags
  common_tags = merge(var.tags, {
    Name        = local.name_prefix
    environment = var.environment
  })
}
