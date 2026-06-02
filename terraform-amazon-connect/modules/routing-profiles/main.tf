resource "aws_connect_routing_profile" "this" {
  for_each = var.routing_profiles

  instance_id               = var.instance_id
  name                      = "${var.name_prefix}-${each.key}"
  description               = each.value.description
  default_outbound_queue_id = var.queue_ids[each.value.default_outbound_queue]

  dynamic "media_concurrencies" {
    for_each = each.value.media_concurrencies
    content {
      channel     = media_concurrencies.value.channel
      concurrency = media_concurrencies.value.concurrency
    }
  }

  dynamic "queue_configs" {
    for_each = each.value.queue_configs
    content {
      queue_id = var.queue_ids[queue_configs.value.queue_key]
      channel  = queue_configs.value.channel
      priority = queue_configs.value.priority
      delay    = queue_configs.value.delay
    }
  }
}
