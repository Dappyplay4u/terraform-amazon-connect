###############################################################################
# S3 Module — Locals
###############################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.region
  partition   = data.aws_partition.current.partition

  # The three Connect S3 storage purposes — names are fixed by Connect API contract
  bucket_definitions = {
    call_recordings = {
      suffix      = "call-recordings"
      description = "Amazon Connect call recordings"
      prefix      = "call-recordings/"
    }
    scheduled_reports = {
      suffix      = "scheduled-reports"
      description = "Amazon Connect scheduled reports"
      prefix      = "scheduled-reports/"
    }
    chat_transcripts = {
      suffix      = "chat-transcripts"
      description = "Amazon Connect chat transcripts"
      prefix      = "chat-transcripts/"
    }
  }

  common_tags = merge(var.tags, {
    environment = var.environment
  })
}
