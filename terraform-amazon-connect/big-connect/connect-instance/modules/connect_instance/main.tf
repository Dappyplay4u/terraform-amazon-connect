###############################################################################
# Connect Instance Module — Main
#
# This module is FULLY SELF-CONTAINED. It:
#   1. Calls modules/kms     → creates s3 / kinesis / connect KMS keys
#   2. Calls modules/s3      → creates call_recordings / scheduled_reports / chat_transcripts buckets
#   3. Calls modules/kinesis → creates CTR + media streams + optional Firehose
#   4. Creates the aws_connect_instance with SAML identity + all 5 features enabled
#   5. Wires all 5 aws_connect_instance_storage_config associations
#   6. Creates the CloudWatch log group for contact flow logs
#
# Callers who already have KMS/S3/Kinesis can pass existing ARNs/IDs via the
# existing_* variables — in that case the child modules are skipped (count = 0).
#
# instance_alias  →  "${var.project_spec}-${var.environment}-${var.aws_region_alias}"
#                    e.g. retail-prod-ue1
# name_prefix     →  "${var.project_name}-${var.environment}"
#                    e.g. retail-connect-prod
###############################################################################

###############################################################################
# 1. KMS — child module (skipped if existing keys are provided)
###############################################################################

module "kms" {
  count  = local.create_kms
  source = "C:/Users/oladapo/OneDrive/Desktop/kms-module/kms"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  key_admin_arns = var.key_admin_arns

  kms_keys = {
    s3      = {}
    kinesis = {}
    connect = {}
  }

  tags = var.tags
}

###############################################################################
# 2. S3 — child module (skipped if existing buckets are provided)
###############################################################################

module "s3" {
  count  = local.create_s3
  source = "C:/Users/oladapo/OneDrive/Desktop/s3-module/modules/s3"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  kms_key_arn   = local.kms_s3_arn
  force_destroy = false

  enable_access_logging              = true
  lifecycle_ia_transition_days       = 90
  lifecycle_glacier_transition_days  = 365
  lifecycle_expiration_days          = 2555
  noncurrent_version_expiration_days = 90

  tags = var.tags

  depends_on = [module.kms]
}

###############################################################################
# 3. Kinesis — child module (skipped if existing streams are provided)
###############################################################################

module "kinesis" {
  count  = local.create_kinesis
  source = "C:/Users/oladapo/OneDrive/Desktop/kinesis-module/modules/kinesis"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  kms_key_id  = local.kms_kinesis_id
  kms_key_arn = local.kms_kinesis_arn

  stream_mode            = var.kinesis_stream_mode
  retention_period_hours = var.kinesis_retention_hours

  enable_firehose_ctr                 = var.enable_firehose_ctr
  ctr_s3_bucket_arn                   = local.create_s3 == 1 ? module.s3[0].call_recordings_bucket_arn : ""
  firehose_buffering_size_mb          = 5
  firehose_buffering_interval_seconds = 300

  enable_cloudwatch_alarms        = true
  iterator_age_alarm_threshold_ms = 60000
  alarm_sns_topic_arns            = var.alarm_sns_topic_arns

  tags = var.tags

  depends_on = [module.kms, module.s3]
}

###############################################################################
# 4. Amazon Connect Instance
###############################################################################

resource "aws_connect_instance" "this" {
  identity_management_type = "SAML"
  instance_alias           = local.instance_alias

  # ── Feature flags — all enabled ─────────────────────────────────────────────
  inbound_calls_enabled            = true
  outbound_calls_enabled           = true
  contact_flow_logs_enabled        = true
  contact_lens_enabled             = true
  early_media_enabled              = true
  multi_party_conference_enabled   = true
  auto_resolve_best_voices_enabled = var.auto_resolve_best_voices_enabled

  tags = merge(local.common_tags, {
    Name = local.instance_alias
  })

  depends_on = [module.kms, module.s3, module.kinesis]
}

###############################################################################
# 5a. Storage: Call Recordings → S3
###############################################################################

resource "aws_connect_instance_storage_config" "call_recordings" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "CALL_RECORDINGS"

  storage_config {
    storage_type = "S3"

    s3_config {
      bucket_name   = local.s3_call_recordings_id
      bucket_prefix = "call-recordings"

      encryption_config {
        encryption_type = "KMS"
        key_id          = local.kms_s3_arn
      }
    }
  }
}

###############################################################################
# 5b. Storage: Scheduled Reports → S3
###############################################################################

resource "aws_connect_instance_storage_config" "scheduled_reports" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "SCHEDULED_REPORTS"

  storage_config {
    storage_type = "S3"

    s3_config {
      bucket_name   = local.s3_scheduled_reports_id
      bucket_prefix = "scheduled-reports"

      encryption_config {
        encryption_type = "KMS"
        key_id          = local.kms_s3_arn
      }
    }
  }
}

###############################################################################
# 5c. Storage: Chat Transcripts → S3
###############################################################################

resource "aws_connect_instance_storage_config" "chat_transcripts" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "CHAT_TRANSCRIPTS"

  storage_config {
    storage_type = "S3"

    s3_config {
      bucket_name   = local.s3_chat_transcripts_id
      bucket_prefix = "chat-transcripts"

      encryption_config {
        encryption_type = "KMS"
        key_id          = local.kms_s3_arn
      }
    }
  }
}

###############################################################################
# 5d. Storage: Contact Trace Records → Kinesis Data Stream
###############################################################################

resource "aws_connect_instance_storage_config" "contact_trace_records" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "CONTACT_TRACE_RECORDS"

  storage_config {
    storage_type = "KINESIS_STREAM"

    kinesis_stream_config {
      stream_arn = local.kinesis_ctr_arn
    }
  }
}

###############################################################################
# 5e. Storage: Media Streams → Kinesis Video Stream
###############################################################################

resource "aws_connect_instance_storage_config" "media_streams" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "MEDIA_STREAMS"

  storage_config {
    storage_type = "KINESIS_VIDEO_STREAM"

    kinesis_video_stream_config {
      prefix                 = "${local.name_prefix}-media"
      retention_period_hours = var.media_stream_retention_hours

      encryption_config {
        encryption_type = "KMS"
        key_id          = local.kms_kinesis_arn
      }
    }
  }
}

###############################################################################
# 6. CloudWatch Log Group — Contact Flow Logs
###############################################################################

resource "aws_cloudwatch_log_group" "contact_flow" {
  name              = "/aws/connect/${local.instance_alias}"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.kms_connect_arn

  tags = merge(local.common_tags, {
    Name = "/aws/connect/${local.instance_alias}"
  })
}
