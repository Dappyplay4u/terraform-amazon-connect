variable "name_prefix" { type = string }
variable "billing_mode" { type = string }
variable "enable_pitr" { type = bool }

variable "tables" {
  type = map(object({
    hash_key  = string
    range_key = optional(string)
    attributes = list(object({
      name = string
      type = string
    }))
    global_secondary_indexes = optional(list(object({
      name            = string
      hash_key        = string
      range_key       = optional(string)
      projection_type = string
    })), [])
    ttl_attribute          = optional(string)
    stream_enabled         = optional(bool, false)
    point_in_time_recovery = optional(bool, false)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
