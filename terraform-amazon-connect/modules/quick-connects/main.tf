resource "aws_connect_quick_connect" "this" {
  for_each = var.quick_connects

  instance_id = var.instance_id
  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description

  quick_connect_config {
    quick_connect_type = each.value.type

    dynamic "phone_config" {
      for_each = each.value.type == "PHONE_NUMBER" ? [1] : []
      content {
        phone_number = each.value.phone_number
      }
    }

    dynamic "queue_config" {
      for_each = each.value.type == "QUEUE" ? [1] : []
      content {
        queue_id        = var.queue_ids[each.value.queue_key]
        contact_flow_id = var.contact_flow_ids[each.value.contact_flow_key]
      }
    }
  }
}
