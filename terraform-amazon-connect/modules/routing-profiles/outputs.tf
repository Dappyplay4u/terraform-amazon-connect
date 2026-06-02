output "routing_profile_ids" {
  value = { for k, r in aws_connect_routing_profile.this : k => r.routing_profile_id }
}

output "routing_profile_arns" {
  value = { for k, r in aws_connect_routing_profile.this : k => r.arn }
}
