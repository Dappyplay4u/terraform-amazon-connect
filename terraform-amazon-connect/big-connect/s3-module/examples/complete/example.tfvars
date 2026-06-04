###############################################################################
# S3 Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
###############################################################################

aws_region   = "us-east-1"
project_name = "retail-connect"
environment  = "prod" # prod | qa | test

kms_key_arn   = "arn:aws:kms:us-east-1:<account_id>:key/<key_id>"
force_destroy = false

# ── Required Tags ──────────────────────────────────────────────────────────────
business_application_id   = "APP-001"
cost_center               = "CC-1234"
created_by                = "platform-team"
technical_support_by      = "cloud-ops"
application_group         = "contact-center"
technical_environment     = "production"
security_data_application = "confidential"
business_application_code = "RETAIL-CC"
