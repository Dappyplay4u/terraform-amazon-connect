output "stream_arns" { value = { for k, v in aws_kinesis_stream.this : k => v.arn } }
output "stream_names" { value = { for k, v in aws_kinesis_stream.this : k => v.name } }
output "ctr_stream_arn" { value = aws_kinesis_stream.this["contact_trace_records"].arn }
output "ctr_stream_name" { value = aws_kinesis_stream.this["contact_trace_records"].name }
output "media_stream_arn" { value = aws_kinesis_stream.this["media_streams"].arn }
output "media_stream_name" { value = aws_kinesis_stream.this["media_streams"].name }
output "firehose_arn" { value = var.enable_firehose_ctr ? aws_kinesis_firehose_delivery_stream.ctr[0].arn : "" }
output "name_prefix" { value = local.name_prefix }
