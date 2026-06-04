###############################################################################
# KMS Module — Outputs
###############################################################################

output "key_arns" {
  description = "Map of key purpose → KMS Key ARN  (e.g. { s3 = \"arn:aws:kms:...\" })"
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "key_ids" {
  description = "Map of key purpose → KMS Key ID"
  value       = { for k, v in aws_kms_key.this : k => v.key_id }
}

output "alias_arns" {
  description = "Map of key purpose → KMS Alias ARN"
  value       = { for k, v in aws_kms_alias.this : k => v.arn }
}

output "alias_names" {
  description = "Map of key purpose → KMS Alias Name  (e.g. alias/retail-connect-prod-s3)"
  value       = { for k, v in aws_kms_alias.this : k => v.name }
}

output "name_prefix" {
  description = "Resolved name_prefix used by this module  (e.g. retail-connect-prod)"
  value       = local.name_prefix
}

# ── Convenience single-key outputs ───────────────────────────────────────────

output "s3_key_arn" {
  description = "KMS Key ARN for S3 encryption"
  value       = lookup(aws_kms_key.this, "s3", null) != null ? aws_kms_key.this["s3"].arn : null
}

output "s3_key_id" {
  description = "KMS Key ID for S3 encryption"
  value       = lookup(aws_kms_key.this, "s3", null) != null ? aws_kms_key.this["s3"].key_id : null
}

output "kinesis_key_arn" {
  description = "KMS Key ARN for Kinesis encryption"
  value       = lookup(aws_kms_key.this, "kinesis", null) != null ? aws_kms_key.this["kinesis"].arn : null
}

output "kinesis_key_id" {
  description = "KMS Key ID for Kinesis encryption"
  value       = lookup(aws_kms_key.this, "kinesis", null) != null ? aws_kms_key.this["kinesis"].key_id : null
}

output "connect_key_arn" {
  description = "KMS Key ARN for Connect/CloudWatch encryption"
  value       = lookup(aws_kms_key.this, "connect", null) != null ? aws_kms_key.this["connect"].arn : null
}

output "connect_key_id" {
  description = "KMS Key ID for Connect/CloudWatch encryption"
  value       = lookup(aws_kms_key.this, "connect", null) != null ? aws_kms_key.this["connect"].key_id : null
}
