output "connect_instance_id" {
  description = "Amazon Connect instance ID."
  value       = module.connect_instance.instance_id
}

output "connect_instance_arn" {
  description = "Amazon Connect instance ARN."
  value       = module.connect_instance.instance_arn
}

output "connect_instance_alias" {
  description = "Amazon Connect instance alias."
  value       = var.instance_alias
}

output "queue_ids" {
  description = "Map of queue key to queue ID."
  value       = module.queues.queue_ids
}

output "routing_profile_ids" {
  description = "Map of routing profile key to ID."
  value       = module.routing_profiles.routing_profile_ids
}

output "contact_flow_ids" {
  description = "Map of contact flow key to ID."
  value       = module.contact_flows.flow_ids
}

output "lambda_function_arns" {
  description = "Map of Lambda key to ARN."
  value       = module.lambda_functions.function_arns
}

output "dynamodb_table_names" {
  description = "Map of DynamoDB table key to table name."
  value       = module.dynamodb_tables.table_names
}

output "dynamodb_table_arns" {
  description = "Map of DynamoDB table key to ARN."
  value       = module.dynamodb_tables.table_arns
}

output "s3_recording_bucket" {
  description = "S3 bucket name for call recordings."
  value       = module.s3_storage.recording_bucket_name
}

output "s3_report_bucket" {
  description = "S3 bucket name for reports."
  value       = module.s3_storage.report_bucket_name
}

output "hours_of_operation_ids" {
  description = "Map of hours-of-operation key to ID."
  value       = module.hours_of_operation.hours_ids
}
