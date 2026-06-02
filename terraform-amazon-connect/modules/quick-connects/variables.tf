variable "instance_id" { type = string }
variable "name_prefix" { type = string }

variable "quick_connects" {
  type = map(object({
    description      = string
    type             = string
    phone_number     = optional(string)
    queue_key        = optional(string)
    contact_flow_key = optional(string)
  }))
  default = {}
}

variable "queue_ids" {
  type = map(string)
}

variable "contact_flow_ids" {
  type = map(string)
}
