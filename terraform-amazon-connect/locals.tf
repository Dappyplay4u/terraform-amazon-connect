locals {
  # Naming convention used everywhere: project-environment-<short>
  name_prefix = "${var.project_name}-${var.environment}"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Standard tags applied to anything that doesn't inherit default_tags
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
  }

  is_prod = var.environment == "prod"
}
