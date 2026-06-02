resource "aws_connect_instance" "this" {
  identity_management_type         = var.identity_management_type
  instance_alias                   = var.instance_alias
  inbound_calls_enabled            = var.inbound_calls_enabled
  outbound_calls_enabled           = var.outbound_calls_enabled
  contact_flow_logs_enabled        = var.enable_contactflow_logs
  contact_lens_enabled             = var.enable_contact_lens
  auto_resolve_best_voices_enabled = var.enable_auto_resolve_best_voices
  early_media_enabled              = true
  multi_party_conference_enabled   = true
}

# Storage config: call recordings -> S3
resource "aws_connect_instance_storage_config" "call_recordings" {
  count = var.enable_call_recording ? 1 : 0

  instance_id   = aws_connect_instance.this.id
  resource_type = "CALL_RECORDINGS"

  storage_config {
    storage_type = "S3"
    s3_config {
      bucket_name   = var.call_recording_bucket
      bucket_prefix = var.call_recording_prefix
    }
  }
}

# Storage config: scheduled reports -> S3
resource "aws_connect_instance_storage_config" "scheduled_reports" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "SCHEDULED_REPORTS"

  storage_config {
    storage_type = "S3"
    s3_config {
      bucket_name   = var.reports_bucket
      bucket_prefix = var.reports_prefix
    }
  }
}

# Storage config: chat transcripts -> S3
resource "aws_connect_instance_storage_config" "chat_transcripts" {
  instance_id   = aws_connect_instance.this.id
  resource_type = "CHAT_TRANSCRIPTS"

  storage_config {
    storage_type = "S3"
    s3_config {
      bucket_name   = var.reports_bucket
      bucket_prefix = "${var.reports_prefix}/chat-transcripts"
    }
  }
}

