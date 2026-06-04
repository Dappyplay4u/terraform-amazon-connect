###############################################################################
# S3 Module — Outputs
###############################################################################

output "bucket_ids" {
  description = "Map of purpose → S3 bucket ID"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "bucket_arns" {
  description = "Map of purpose → S3 bucket ARN"
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}

output "call_recordings_bucket_id" {
  description = "S3 bucket ID for call recordings (used by connect_instance module)"
  value       = aws_s3_bucket.this["call_recordings"].id
}

output "call_recordings_bucket_arn" {
  description = "S3 bucket ARN for call recordings"
  value       = aws_s3_bucket.this["call_recordings"].arn
}

output "scheduled_reports_bucket_id" {
  description = "S3 bucket ID for scheduled reports (used by connect_instance module)"
  value       = aws_s3_bucket.this["scheduled_reports"].id
}

output "scheduled_reports_bucket_arn" {
  description = "S3 bucket ARN for scheduled reports"
  value       = aws_s3_bucket.this["scheduled_reports"].arn
}

output "chat_transcripts_bucket_id" {
  description = "S3 bucket ID for chat transcripts (used by connect_instance module)"
  value       = aws_s3_bucket.this["chat_transcripts"].id
}

output "chat_transcripts_bucket_arn" {
  description = "S3 bucket ARN for chat transcripts"
  value       = aws_s3_bucket.this["chat_transcripts"].arn
}

output "access_logs_bucket_id" {
  description = "S3 access-log bucket ID (empty string if disabled)"
  value       = var.enable_access_logging ? aws_s3_bucket.access_logs[0].id : ""
}

output "name_prefix" {
  description = "Resolved name_prefix used by this module"
  value       = local.name_prefix
}
