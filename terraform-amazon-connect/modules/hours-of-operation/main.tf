resource "aws_connect_hours_of_operation" "this" {
  for_each = var.hours_of_operation

  instance_id = var.instance_id
  name        = each.key
  description = each.value.description
  time_zone   = each.value.time_zone

  dynamic "config" {
    for_each = each.value.config
    content {
      day = config.value.day
      start_time {
        hours   = config.value.start_hours
        minutes = config.value.start_mins
      }
      end_time {
        hours   = config.value.end_hours
        minutes = config.value.end_mins
      }
    }
  }
}
