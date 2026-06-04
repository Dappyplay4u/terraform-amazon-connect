###############################################################################
# Connect Instance Module — Outputs
###############################################################################

output "instance_id" { value = aws_connect_instance.this.id }
output "instance_arn" { value = aws_connect_instance.this.arn }
output "instance_alias" { value = aws_connect_instance.this.instance_alias }
output "service_role" { value = aws_connect_instance.this.service_role }
output "name_prefix" { value = local.name_prefix }

output "contact_flow_log_group_name" { value = aws_cloudwatch_log_group.contact_flow.name }
output "contact_flow_log_group_arn" { value = aws_cloudwatch_log_group.contact_flow.arn }

# ── Child module outputs (available to callers that want to reference them) ──

output "kms_key_arns" {
  description = "KMS key ARNs created by this module (empty map if existing keys were passed in)"
  value       = local.create_kms == 1 ? module.kms[0].key_arns : {}
}

output "s3_bucket_ids" {
  description = "S3 bucket IDs created by this module (empty map if existing buckets were passed in)"
  value       = local.create_s3 == 1 ? module.s3[0].bucket_ids : {}
}

output "kinesis_stream_arns" {
  description = "Kinesis stream ARNs created by this module (empty map if existing streams were passed in)"
  value       = local.create_kinesis == 1 ? module.kinesis[0].stream_arns : {}
}
