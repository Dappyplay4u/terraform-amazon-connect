###############################################################################
# KMS Complete Example — Locals
###############################################################################

locals {
  required_tags = {
    business_application_id   = var.business_application_id
    cost_center               = var.cost_center
    created_by                = var.created_by
    technical_support_by      = var.technical_support_by
    application_group         = var.application_group
    technical_environment     = var.technical_environment
    security_data_application = var.security_data_application
    business_application_code = var.business_application_code
  }
}
