output "table_names" {
  value = { for k, t in aws_dynamodb_table.this : k => t.name }
}

output "table_arns" {
  value = { for k, t in aws_dynamodb_table.this : k => t.arn }
}

output "stream_arns" {
  value = { for k, t in aws_dynamodb_table.this : k => t.stream_arn if t.stream_enabled }
}
