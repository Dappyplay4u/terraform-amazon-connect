variable "name_prefix" { type = string }
variable "enable_versioning" { type = bool }
variable "recording_lifecycle_days" { type = number }
variable "report_lifecycle_days" { type = number }
variable "use_customer_managed_kms" { type = bool }

variable "tags" {
  type    = map(string)
  default = {}
}
