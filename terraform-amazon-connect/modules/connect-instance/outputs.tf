output "instance_id" {
  value = aws_connect_instance.this.id
}

output "instance_arn" {
  value = aws_connect_instance.this.arn
}

output "service_role" {
  value = aws_connect_instance.this.service_role
}
