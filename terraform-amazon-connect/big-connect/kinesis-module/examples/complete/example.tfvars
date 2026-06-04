###############################################################################
# Kinesis Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
###############################################################################

aws_region   = "us-east-1"
project_name = "retail-connect"
environment  = "prod" # prod | qa | test

kms_key_id        = "<kinesis-kms-key-id>"
kms_key_arn       = "arn:aws:kms:us-east-1:<account_id>:key/<kinesis-key-id>"
ctr_s3_bucket_arn = "arn:aws:s3:::retail-connect-prod-call-recordings"

alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:connect-alerts-prod",
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
