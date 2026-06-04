###############################################################################
# Kinesis Module — Locals
###############################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.region
  partition   = data.aws_partition.current.partition

  # Fixed stream definitions — names align with Connect storage resource_type
  stream_definitions = {
    contact_trace_records = {
      suffix      = "ctr"
      description = "Amazon Connect Contact Trace Records"
    }
    media_streams = {
      suffix      = "media"
      description = "Amazon Connect Media Streams"
    }
  }

  common_tags = merge(var.tags, {
    environment = var.environment
  })
}
