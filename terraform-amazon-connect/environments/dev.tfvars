###############################################################################
# DEV environment — env-specific values only.
# Resource maps (queues, flows, lambdas, ddb, etc) come from _shared.tfvars.
#
# Apply with:
#   terraform apply -var-file=environments/_shared.tfvars -var-file=environments/dev.tfvars
###############################################################################

project_name   = "acme-cc"
environment    = "dev"
aws_region     = "us-east-1"
cost_center    = "cc-dev"
instance_alias = "acme-cc-dev"

# Connect instance flags — outbound disabled in dev to avoid accidental dialing
inbound_calls_enabled   = true
outbound_calls_enabled  = false
enable_contact_lens     = false
enable_contactflow_logs = true
enable_call_recording   = true

# Cheaper settings for dev
dynamodb_billing_mode       = "PAY_PER_REQUEST"
lambda_log_retention_days   = 14
enable_s3_versioning        = false
use_customer_managed_kms    = false
s3_lifecycle_recording_days = 30
s3_lifecycle_report_days    = 90
