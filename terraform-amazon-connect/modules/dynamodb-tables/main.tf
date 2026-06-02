resource "aws_dynamodb_table" "this" {
  for_each = var.tables

  name         = "${var.name_prefix}-${each.key}"
  billing_mode = var.billing_mode
  hash_key     = each.value.hash_key
  range_key    = each.value.range_key

  # Provisioned capacity only when not PAY_PER_REQUEST
  read_capacity  = var.billing_mode == "PROVISIONED" ? 5 : null
  write_capacity = var.billing_mode == "PROVISIONED" ? 5 : null

  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type

      read_capacity  = var.billing_mode == "PROVISIONED" ? 5 : null
      write_capacity = var.billing_mode == "PROVISIONED" ? 5 : null
    }
  }

  dynamic "ttl" {
    for_each = each.value.ttl_attribute != null ? [each.value.ttl_attribute] : []
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }

  stream_enabled   = each.value.stream_enabled
  stream_view_type = each.value.stream_enabled ? "NEW_AND_OLD_IMAGES" : null

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.tags, { TableName = each.key })
}
