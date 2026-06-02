variable "instance_id" { type = string }

variable "hours_of_operation" {
  type = map(object({
    description = string
    time_zone   = string
    config = list(object({
      day         = string
      start_hours = number
      start_mins  = number
      end_hours   = number
      end_mins    = number
    }))
  }))
}
