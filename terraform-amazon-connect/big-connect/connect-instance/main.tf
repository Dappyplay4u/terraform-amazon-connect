###############################################################################
# Connect Instance — Root
#
# Run from the repo root:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan -var-file="terraform.tfvars"
#   terraform apply -var-file="terraform.tfvars"
###############################################################################

module "connect" {
  source = "./modules/connect_instance"

  # ── Region ──────────────────────────────────────────────────────────────────
  aws_region = var.aws_region

  # ── Naming ──────────────────────────────────────────────────────────────────
  project_spec     = var.project_spec
  project_name     = var.project_name
  environment      = var.environment
  aws_region_alias = var.aws_region_alias

  # ── Connect feature flags ────────────────────────────────────────────────────
  auto_resolve_best_voices_enabled = true
  media_stream_retention_hours     = 24
  log_retention_days               = 365

  # ── Bring-your-own resources (leave "" to auto-create) ───────────────────────
  existing_kms_s3_arn              = ""
  existing_kms_kinesis_arn         = ""
  existing_kms_connect_arn         = ""
  existing_s3_call_recordings_id   = ""
  existing_s3_scheduled_reports_id = ""
  existing_s3_chat_transcripts_id  = ""
  existing_kinesis_ctr_arn         = ""

  # ── KMS admin ARNs ───────────────────────────────────────────────────────────
  key_admin_arns = var.key_admin_arns

  # ── Kinesis settings ─────────────────────────────────────────────────────────
  kinesis_stream_mode     = "ON_DEMAND"
  kinesis_retention_hours = 24
  enable_firehose_ctr     = true

  # ── CloudWatch alarm notifications ───────────────────────────────────────────
  alarm_sns_topic_arns = var.alarm_sns_topic_arns

  # ── Required tags ────────────────────────────────────────────────────────────
  tags = local.required_tags
}
