output "hours_ids" {
  value = { for k, h in aws_connect_hours_of_operation.this : k => h.hours_of_operation_id }
}

output "hours_arns" {
  value = { for k, h in aws_connect_hours_of_operation.this : k => h.arn }
}
