variable "instance_id" { type = string }
variable "name_prefix" { type = string }
variable "content_root" { type = string }

variable "contact_flows" {
  type = map(object({
    description  = string
    type         = string
    content_file = string
  }))
}

variable "substitutions" {
  description = "Variables substituted into the flow JSON templates."
  type        = map(string)
  default     = {}
}
