variable "name_prefix" { type = string }
variable "dynamodb_table_arns" { type = map(string) }
variable "s3_recording_bucket_arn" { type = string }
variable "s3_report_bucket_arn" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}
