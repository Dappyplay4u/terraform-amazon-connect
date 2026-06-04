# Amazon Connect Instance — Deployment Runbook

## Overview

This runbook covers the end-to-end steps to deploy the `connect_instance` module.  
The module auto-creates the following resources (unless you bring your own):

| Resource | Name pattern |
|---|---|
| KMS keys (×3) | `alias/<name_prefix>-s3` / `-kinesis` / `-connect` |
| S3 buckets (×3) | `<name_prefix>-call-recordings` / `-scheduled-reports` / `-chat-transcripts` |
| Kinesis Data Streams (×2) | `<name_prefix>-connect-ctr` / `-connect-media` |
| Kinesis Firehose | `<name_prefix>-connect-ctr-firehose` |
| Connect Instance | alias: `<project_spec>-<environment>-<region_alias>` e.g. `retail-prod-ue1` |
| CloudWatch Log Group | `/aws/connect/<instance_alias>` |

---

## Prerequisites

### 1. Tools
| Tool | Minimum version | Check |
|---|---|---|
| Terraform | `>= 1.5.0` | `terraform version` |
| AWS CLI | `>= 2.x` | `aws --version` |

### 2. AWS Permissions
The IAM principal running Terraform must have permissions for:
- `kms:*` — create and manage KMS keys
- `s3:*` — create and configure S3 buckets
- `kinesis:*` — create Kinesis streams
- `firehose:*` — create Kinesis Firehose delivery streams
- `connect:*` — create and configure the Connect instance
- `logs:*` — create CloudWatch log groups
- `iam:PassRole` — pass the Connect service role
- `cloudwatch:PutMetricAlarm` — create alarms (if SNS alarms enabled)

Verify your identity before proceeding:
```bash
aws sts get-caller-identity
```

### 3. Module Source Paths
The `connect_instance` module references these standalone modules on disk.  
Confirm each path exists before running `terraform init`:

```
C:\Users\oladapo\OneDrive\Desktop\kms-module\kms
C:\Users\oladapo\OneDrive\Desktop\s3-module\modules\s3
C:\Users\oladapo\OneDrive\Desktop\kinesis-module\modules\kinesis
```

---

## Deployment Steps

### Step 1 — Navigate to the examples directory

```bash
cd "C:\Users\oladapo\OneDrive\Desktop\connect-instance\modules\connect_instance\examples"
```

---

### Step 2 — Create your tfvars file

Copy the example and fill in your values:

```bash
copy example.tfvars terraform.tfvars
```

Edit `terraform.tfvars`. All fields are required:

```hcl
# ── Region ────────────────────────────────────────────────────────────────────
aws_region = "us-east-1"

# ── Naming ────────────────────────────────────────────────────────────────────
# instance_alias  →  "<project_spec>-<environment>-<aws_region_alias>"  e.g. retail-prod-ue1
# name_prefix     →  "<project_name>-<environment>"                     e.g. retail-connect-prod
project_spec     = "retail"
project_name     = "retail-connect"
environment      = "prod"           # prod | qa | test
aws_region_alias = "ue1"            # ue1 | ue2 | uw1 | uw2 | ew1 | ec1

# ── KMS key administrators ────────────────────────────────────────────────────
key_admin_arns = [
  "arn:aws:iam::<account_id>:role/<TerraformDeployRole>",
]

# ── CloudWatch alarm notifications (optional) ─────────────────────────────────
alarm_sns_topic_arns = [
  # "arn:aws:sns:us-east-1:<account_id>:connect-alerts-prod",
]

# ── Required Tags ─────────────────────────────────────────────────────────────
business_application_id   = "APP-001"
cost_center               = "CC-1234"
created_by                = "platform-team"
technical_support_by      = "cloud-ops"
application_group         = "contact-center"
technical_environment     = "production"
security_data_application = "confidential"
business_application_code = "RETAIL-CC"
```

> **Bring-your-own resources** — if KMS keys, S3 buckets, or Kinesis streams already exist,
> add any of the following to your `terraform.tfvars` to skip auto-creation:
> ```hcl
> existing_kms_s3_arn              = "arn:aws:kms:us-east-1:<account_id>:key/<key_id>"
> existing_kms_kinesis_arn         = "arn:aws:kms:us-east-1:<account_id>:key/<key_id>"
> existing_kms_connect_arn         = "arn:aws:kms:us-east-1:<account_id>:key/<key_id>"
> existing_s3_call_recordings_id   = "<bucket_name>"
> existing_s3_scheduled_reports_id = "<bucket_name>"
> existing_s3_chat_transcripts_id  = "<bucket_name>"
> existing_kinesis_ctr_arn         = "arn:aws:kinesis:us-east-1:<account_id>:stream/<stream_name>"
> ```

---

### Step 3 — Configure the backend (optional but recommended for teams)

Open `provider.tf` and uncomment the S3 backend block, replacing placeholder values:

```hcl
backend "s3" {
  bucket         = "<your-tf-state-bucket>"
  key            = "connect/instances/<project_spec>-<environment>-<region_alias>/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

Skip this step if using the local backend (default).

---

### Step 4 — Initialise Terraform

```bash
terraform init
```

Expected output confirms three module sources are downloaded:
```
Initializing modules...
- connect.module.kms in C:\Users\oladapo\OneDrive\Desktop\kms-module\kms
- connect.module.s3  in C:\Users\oladapo\OneDrive\Desktop\s3-module\modules\s3
- connect.module.kinesis in C:\Users\oladapo\OneDrive\Desktop\kinesis-module\modules\kinesis
```

If init fails with **"Invalid module source"**, verify the three module paths exist (see Prerequisites §3).

---

### Step 5 — Validate configuration

```bash
terraform validate
```

All outputs must show `Success`. Fix any reported errors before continuing.

---

### Step 6 — Plan

```bash
terraform plan -var-file="terraform.tfvars" -out=tfplan
```

Review the plan output. Expected resource count for a full auto-create deployment:

| Resource type | Count |
|---|---|
| `aws_kms_key` | 3 |
| `aws_kms_alias` | 3 |
| `aws_s3_bucket` + policies/configs | ~15 |
| `aws_kinesis_stream` | 2 |
| `aws_kinesis_firehose_delivery_stream` | 1 (if `enable_firehose_ctr = true`) |
| `aws_connect_instance` | 1 |
| `aws_connect_instance_storage_config` | 5 |
| `aws_cloudwatch_log_group` | 1 |
| `aws_cloudwatch_metric_alarm` | 1–2 (if alarms enabled) |

Confirm no unexpected **destroy** actions appear before proceeding.

---

### Step 7 — Apply

```bash
terraform apply tfplan
```

Type `yes` when prompted (or use `-auto-approve` for CI pipelines).

Deployment typically takes **3–6 minutes**. The Connect instance provisioning step is the longest.

---

### Step 8 — Verify outputs

```bash
terraform output
```

Expected outputs:

```
contact_flow_log_group_name = "/aws/connect/retail-prod-ue1"
instance_alias              = "retail-prod-ue1"
instance_arn                = "arn:aws:connect:us-east-1:<account_id>:instance/<instance_id>"
instance_id                 = "<instance_id>"
kinesis_stream_arns         = { ... }
name_prefix                 = "retail-connect-prod"
s3_bucket_ids               = { ... }
```

> `kms_key_arns` is marked sensitive — retrieve it with:
> ```bash
> terraform output -json kms_key_arns
> ```

---

### Step 9 — Smoke test

Run these AWS CLI checks against the deployed resources:

```bash
# 1. Confirm Connect instance is ACTIVE
aws connect list-instances --query "InstanceSummaryList[?InstanceAlias=='retail-prod-ue1']"

# 2. Confirm all 5 storage configs are attached
aws connect list-instance-storage-configs \
  --instance-id <instance_id> \
  --resource-type CALL_RECORDINGS

# 3. Confirm CloudWatch log group exists
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/connect/retail-prod-ue1"

# 4. Confirm KMS keys are enabled
aws kms describe-key --key-id alias/retail-connect-prod-s3 \
  --query "KeyMetadata.KeyState"
```

All checks should return non-empty results and `"Enabled"` key state.

---

## Environment-specific Deployments

To deploy to a different environment, create a separate tfvars file per environment and use isolated state keys:

```bash
# QA
terraform plan -var-file="qa.tfvars" -out=tfplan-qa
terraform apply tfplan-qa

# Production
terraform plan -var-file="prod.tfvars" -out=tfplan-prod
terraform apply tfplan-prod
```

Recommended `state key` pattern per environment:
```
connect/instances/<project_spec>-<environment>-<region_alias>/terraform.tfstate
```

---

## Destroying the Stack

> **Warning:** This permanently deletes the Connect instance, all S3 data (unless `force_destroy = false` blocks the bucket deletion), KMS keys, and Kinesis streams.

```bash
terraform destroy -var-file="terraform.tfvars"
```

If S3 deletion is blocked by `force_destroy = false`, manually empty the buckets first:

```bash
aws s3 rm s3://<bucket_name> --recursive
```

Then re-run `terraform destroy`.

---

## Troubleshooting

| Error | Likely cause | Fix |
|---|---|---|
| `Invalid module source` on `init` | Standalone module path missing or wrong | Verify the 3 module paths in Prerequisites §3 |
| `Error: Instance alias already exists` | A Connect instance with that alias exists in the account | Change `project_spec`, `environment`, or `aws_region_alias` in tfvars |
| `AccessDenied on kms:CreateKey` | IAM role lacks KMS permissions | Attach `kms:*` or use an existing key via `existing_kms_*` vars |
| `BucketAlreadyExists` | S3 bucket name collision | Use `existing_s3_*` vars to point to the existing bucket |
| `tags` validation error | Missing one of the 8 required tag keys | Ensure all 8 tag keys are present in `terraform.tfvars` |
| `environment` validation error | Value outside prod/qa/test | Use only `prod`, `qa`, or `test` |
| Kinesis alarm not created | `alarm_sns_topic_arns` is empty | Add an SNS topic ARN or ignore if alarms are not needed |
