output "flow_ids" {
  value = { for k, f in aws_connect_contact_flow.this : k => f.contact_flow_id }
}

output "flow_arns" {
  value = { for k, f in aws_connect_contact_flow.this : k => f.arn }
}
