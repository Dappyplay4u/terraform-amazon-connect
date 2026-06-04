###############################################################################
# Connect Instance Module — Locals
#
# instance_alias = "${var.project_spec}-${var.environment}-${var.aws_region_alias}"
#                  example: retail-prod-ue1
#
# name_prefix    = "${var.project_name}-${var.environment}"
#                  example: retail-connect-prod
###############################################################################

locals {
  # ── Core naming ─────────────────────────────────────────────────────────────
  instance_alias = "${var.project_spec}-${var.environment}-${var.aws_region_alias}"
  name_prefix    = "${var.project_name}-${var.environment}"

  # ── Data source shortcuts ────────────────────────────────────────────────────
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  partition  = data.aws_partition.current.partition

  # ── Resolved KMS ARNs ────────────────────────────────────────────────────────
  # If caller passes pre-created KMS ARNs, use them directly.
  # If not (empty string), fall through to the child kms module outputs.
  kms_s3_arn      = var.existing_kms_s3_arn != "" ? var.existing_kms_s3_arn : module.kms[0].s3_key_arn
  kms_s3_id       = var.existing_kms_s3_arn != "" ? var.existing_kms_s3_arn : module.kms[0].s3_key_id
  kms_kinesis_arn = var.existing_kms_kinesis_arn != "" ? var.existing_kms_kinesis_arn : module.kms[0].kinesis_key_arn
  kms_kinesis_id  = var.existing_kms_kinesis_arn != "" ? var.existing_kms_kinesis_arn : module.kms[0].kinesis_key_id
  kms_connect_arn = var.existing_kms_connect_arn != "" ? var.existing_kms_connect_arn : module.kms[0].connect_key_arn

  # ── Resolved S3 bucket IDs ───────────────────────────────────────────────────
  s3_call_recordings_id   = var.existing_s3_call_recordings_id != "" ? var.existing_s3_call_recordings_id : module.s3[0].call_recordings_bucket_id
  s3_scheduled_reports_id = var.existing_s3_scheduled_reports_id != "" ? var.existing_s3_scheduled_reports_id : module.s3[0].scheduled_reports_bucket_id
  s3_chat_transcripts_id  = var.existing_s3_chat_transcripts_id != "" ? var.existing_s3_chat_transcripts_id : module.s3[0].chat_transcripts_bucket_id

  # ── Resolved Kinesis stream ARN ──────────────────────────────────────────────
  kinesis_ctr_arn = var.existing_kinesis_ctr_arn != "" ? var.existing_kinesis_ctr_arn : module.kinesis[0].ctr_stream_arn

  # ── Whether to create child modules ──────────────────────────────────────────
  create_kms     = var.existing_kms_s3_arn == "" ? 1 : 0
  create_s3      = var.existing_s3_call_recordings_id == "" ? 1 : 0
  create_kinesis = var.existing_kinesis_ctr_arn == "" ? 1 : 0

  # ── Common tags ──────────────────────────────────────────────────────────────
  common_tags = merge(var.tags, {
    environment    = var.environment
    instance_alias = local.instance_alias
  })
}
