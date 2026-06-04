###############################################################################
# KMS Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
###############################################################################

aws_region   = "us-east-1"
project_name = "retail-connect"
environment  = "prod" # prod | qa | test

key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/TerraformDeployRole",
]

# ── Required Tags ──────────────────────────────────────────────────────────────
business_application_id   = "APP-001"
cost_center               = "CC-1234"
created_by                = "platform-team"
technical_support_by      = "cloud-ops"
application_group         = "contact-center"
technical_environment     = "production"
security_data_application = "confidential"
business_application_code = "RETAIL-CC"
