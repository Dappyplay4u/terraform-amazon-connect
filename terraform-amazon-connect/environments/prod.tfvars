###############################################################################
# PROD environment — env-specific values only.
# Resource maps come from _shared.tfvars.
#
# Apply with:
#   terraform apply -var-file=environments/_shared.tfvars -var-file=environments/prod.tfvars
###############################################################################

project_name   = "acme-cc"
environment    = "prod"
aws_region     = "us-east-1"
cost_center    = "cc-prod"
instance_alias = "acme-cc-prod"

inbound_calls_enabled   = true
outbound_calls_enabled  = true
enable_contact_lens     = true
enable_contactflow_logs = true
enable_call_recording   = true

dynamodb_billing_mode       = "PROVISIONED"
lambda_log_retention_days   = 90
enable_s3_versioning        = true
use_customer_managed_kms    = true
s3_lifecycle_recording_days = 180
s3_lifecycle_report_days    = 730
