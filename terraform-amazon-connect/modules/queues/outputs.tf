output "queue_ids" {
  description = "Map of queue key to queue ID."
  value       = { for k, q in aws_connect_queue.this : k => q.queue_id }
}

output "queue_arns" {
  description = "Map of queue key to queue ARN."
  value       = { for k, q in aws_connect_queue.this : k => q.arn }
}
