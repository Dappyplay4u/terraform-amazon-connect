locals {
  # Read and template each flow's JSON content
  flow_content = {
    for k, v in var.contact_flows : k => templatefile(
      "${var.content_root}/${v.content_file}",
      var.substitutions,
    )
  }
}

resource "aws_connect_contact_flow" "this" {
  for_each = var.contact_flows

  instance_id = var.instance_id
  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  type        = each.value.type
  content     = local.flow_content[each.key]

  # Force recreate when the JSON content changes
  tags = {
    ContentHash = substr(sha256(local.flow_content[each.key]), 0, 12)
  }
}
