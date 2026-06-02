variable "name_prefix" { type = string }
variable "source_root" { type = string }
variable "execution_role_arn" { type = string }
variable "log_retention_days" { type = number }

variable "functions" {
  type = map(object({
    description            = string
    handler                = string
    runtime                = string
    timeout                = optional(number, 15)
    memory_size            = optional(number, 256)
    source_dir             = string
    environment            = optional(map(string), {})
    dynamodb_access        = optional(list(string), [])
    associate_with_connect = optional(bool, true)
  }))
}

variable "dynamodb_table_names" {
  type = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
