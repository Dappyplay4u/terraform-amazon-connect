###############################################################################
# S3 Module — Complete Example
#
# Run from this directory:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan
#   terraform apply
###############################################################################

module "s3" {
  source = "../../modules/s3"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  kms_key_arn   = var.kms_key_arn
  force_destroy = var.force_destroy

  enable_access_logging              = true
  lifecycle_ia_transition_days       = 90
  lifecycle_glacier_transition_days  = 365
  lifecycle_expiration_days          = 2555
  noncurrent_version_expiration_days = 90

  tags = local.required_tags
}
