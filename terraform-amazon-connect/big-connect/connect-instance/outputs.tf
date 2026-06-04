###############################################################################
# Connect Instance — Root Outputs
###############################################################################

output "instance_id" {
  description = "Amazon Connect instance ID"
  value       = module.connect.instance_id
}

output "instance_arn" {
  description = "Amazon Connect instance ARN"
  value       = module.connect.instance_arn
}

output "instance_alias" {
  description = "Resolved instance alias (e.g. retail-prod-ue1)"
  value       = module.connect.instance_alias
}

output "name_prefix" {
  description = "Resolved name prefix (e.g. retail-connect-prod)"
  value       = module.connect.name_prefix
}

output "contact_flow_log_group_name" {
  description = "CloudWatch log group name for contact flow logs"
  value       = module.connect.contact_flow_log_group_name
}

output "kms_key_arns" {
  description = "KMS key ARNs created by this deployment"
  value       = module.connect.kms_key_arns
  sensitive   = true
}

output "s3_bucket_ids" {
  description = "S3 bucket IDs created by this deployment"
  value       = module.connect.s3_bucket_ids
}

output "kinesis_stream_arns" {
  description = "Kinesis stream ARNs created by this deployment"
  value       = module.connect.kinesis_stream_arns
}
