output "quick_connect_ids" {
  value = { for k, q in aws_connect_quick_connect.this : k => q.quick_connect_id }
}

output "quick_connect_arns" {
  value = { for k, q in aws_connect_quick_connect.this : k => q.arn }
}
