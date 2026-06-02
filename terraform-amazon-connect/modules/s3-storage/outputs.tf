output "recording_bucket_name" {
  value = aws_s3_bucket.recordings.id
}

output "recording_bucket_arn" {
  value = aws_s3_bucket.recordings.arn
}

output "report_bucket_name" {
  value = aws_s3_bucket.reports.id
}

output "report_bucket_arn" {
  value = aws_s3_bucket.reports.arn
}

output "exports_bucket_name" {
  value = aws_s3_bucket.exports.id
}

output "exports_bucket_arn" {
  value = aws_s3_bucket.exports.arn
}

output "kms_key_arn" {
  value = var.use_customer_managed_kms ? aws_kms_key.s3[0].arn : null
}
