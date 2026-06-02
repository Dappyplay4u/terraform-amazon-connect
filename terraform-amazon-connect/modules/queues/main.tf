resource "aws_connect_queue" "this" {
  for_each = var.queues

  instance_id           = var.instance_id
  name                  = "${var.name_prefix}-${each.key}"
  description           = each.value.description
  hours_of_operation_id = var.hours_of_operation_ids[each.value.hours_of_operation]
  max_contacts          = each.value.max_contacts

  dynamic "outbound_caller_config" {
    for_each = (each.value.outbound_caller_id_number != null || each.value.outbound_caller_id_name != null) ? [1] : []
    content {
      outbound_caller_id_number_id = each.value.outbound_caller_id_number
      outbound_caller_id_name      = each.value.outbound_caller_id_name
    }
  }
}
