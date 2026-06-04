###############################################################################
# Connect Instance Complete Example — example.tfvars
#
# Copy to terraform.tfvars:
#   cp example.tfvars terraform.tfvars
#
# What this deploys (all auto-created):
#   KMS keys   →  alias/retail-connect-prod-s3 | -kinesis | -connect
#   S3 buckets →  retail-connect-prod-call-recordings
#                 retail-connect-prod-scheduled-reports
#                 retail-connect-prod-chat-transcripts
#   Kinesis    →  retail-connect-prod-connect-ctr
#                 retail-connect-prod-connect-media
#   Firehose   →  retail-connect-prod-connect-ctr-firehose
#   Connect    →  instance alias: retail-prod-ue1
#   CloudWatch →  /aws/connect/retail-prod-ue1
###############################################################################

# ── Region ────────────────────────────────────────────────────────────────────
aws_region = "us-east-1"

# ── Naming ────────────────────────────────────────────────────────────────────
project_spec     = "retail"         # used in instance alias
project_name     = "retail-connect" # used in name_prefix
environment      = "prod"           # prod | qa | test
aws_region_alias = "ue1"            # ue1 | ue2 | uw1 | uw2 | ew1 | ec1

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  # "arn:aws:iam::<account_id>:role/TerraformDeployRole",
]

# ── CloudWatch alarm SNS topics ───────────────────────────────────────────────
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
