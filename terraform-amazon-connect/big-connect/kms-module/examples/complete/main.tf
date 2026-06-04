###############################################################################
# KMS Module — Complete Example
#
# Run from this directory:
#   cp example.tfvars terraform.tfvars
#   terraform init
#   terraform plan
#   terraform apply
###############################################################################

module "kms" {
  source = "../../kms"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  key_admin_arns = var.key_admin_arns

  kms_keys = {
    s3      = {} # defaults: s3.amazonaws.com + connect.amazonaws.com
    kinesis = {} # defaults: kinesis.amazonaws.com + firehose.amazonaws.com
    connect = {} # defaults: connect.amazonaws.com + logs.<region>.amazonaws.com
  }

  tags = local.required_tags
}
