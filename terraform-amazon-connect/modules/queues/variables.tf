variable "instance_id" { type = string }
variable "name_prefix" { type = string }

variable "queues" {
  type = map(object({
    description               = string
    hours_of_operation        = string
    max_contacts              = optional(number)
    outbound_caller_id_number = optional(string)
    outbound_caller_id_name   = optional(string)
    quick_connect_keys        = optional(list(string), [])
  }))
}

variable "hours_of_operation_ids" {
  description = "Map of hours-of-operation key to ID."
  type        = map(string)
}
