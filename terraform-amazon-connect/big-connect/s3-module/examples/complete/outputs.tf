###############################################################################
# S3 Complete Example — Outputs
###############################################################################

output "bucket_ids" {
  description = "Map of purpose → S3 bucket ID"
  value       = module.s3.bucket_ids
}

output "bucket_arns" {
  description = "Map of purpose → S3 bucket ARN"
  value       = module.s3.bucket_arns
}

output "access_logs_bucket_id" {
  description = "S3 access-log bucket ID"
  value       = module.s3.access_logs_bucket_id
}

output "name_prefix" {
  description = "Resolved name prefix used by the module"
  value       = module.s3.name_prefix
}
