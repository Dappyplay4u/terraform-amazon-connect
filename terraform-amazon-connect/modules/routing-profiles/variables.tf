variable "instance_id" { type = string }
variable "name_prefix" { type = string }

variable "routing_profiles" {
  type = map(object({
    description            = string
    default_outbound_queue = string
    media_concurrencies = list(object({
      channel     = string
      concurrency = number
    }))
    queue_configs = list(object({
      queue_key = string
      channel   = string
      priority  = number
      delay     = number
    }))
  }))
}

variable "queue_ids" {
  type = map(string)
}
