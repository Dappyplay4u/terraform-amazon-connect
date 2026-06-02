# Terraform Module — Amazon Connect Full Solution

Production-ready, multi-environment Terraform module that provisions a complete Amazon Connect contact center, including queues, routing profiles, contact flows, Lambda integrations, DynamoDB persistence, S3 storage for recordings/reports, IAM, and Lex bots.

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │       Amazon Connect Instance        │
                    └──────────────┬──────────────────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
   ┌────▼─────┐            ┌───────▼────────┐         ┌───────▼────────┐
   │  Queues  │            │ Contact Flows  │         │  Routing       │
   │ (8 total)│            │  (10 total)    │         │  Profiles (5)  │
   └────┬─────┘            └───────┬────────┘         └────────────────┘
        │                          │
        │                  ┌───────▼────────────────────┐
        │                  │   Lambda Integrations (7)  │
        │                  ├────────────────────────────┤
        │                  │ • customer-lookup          │
        │                  │ • call-logger              │
        │                  │ • callback-scheduler       │
        │                  │ • business-hours-check     │
        │                  │ • crm-integration          │
        │                  │ • post-call-survey         │
        │                  │ • agent-screen-pop         │
        │                  └────────────┬───────────────┘
        │                               │
        │                  ┌────────────▼───────────────┐
        │                  │   DynamoDB Tables (6)      │
        │                  ├────────────────────────────┤
        │                  │ • customers                │
        │                  │ • call-records             │
        │                  │ • callback-requests        │
        │                  │ • agent-stats              │
        │                  │ • survey-responses         │
        │                  │ • configuration            │
        │                  └────────────────────────────┘
        │
   ┌────▼──────────────────────────────────┐
   │  S3 — recordings, reports, exports    │
   └───────────────────────────────────────┘
```

## What the module provisions

| Component             | Count | Examples                                                                                       |
|-----------------------|-------|------------------------------------------------------------------------------------------------|
| Connect instance      | 1     | Per environment                                                                                |
| Queues                | 8     | sales, support-tier1, support-tier2, billing, technical, vip, callback, overflow               |
| Routing profiles      | 5     | sales-agents, support-agents, billing-agents, technical-agents, vip-agents                     |
| Hours of operation    | 3     | business-hours, extended-hours, 24x7                                                           |
| Contact flows         | 10    | inbound-main, inbound-auth, queue-customer, customer-hold, customer-whisper, agent-whisper, outbound-whisper, transfer, callback, post-call-survey |
| Lambda functions      | 7     | See architecture                                                                                |
| DynamoDB tables       | 6     | See architecture                                                                                |
| S3 buckets            | 3     | call-recordings, reports, exported-reports                                                     |
| Lex bots              | 2     | intent-router, authentication                                                                  |
| Quick connects        | 3     | supervisor, billing-team, technical-team                                                       |

## Layout

```
terraform-amazon-connect/
├── main.tf                       # Root composition — wires sub-modules together
├── variables.tf                  # Root variables
├── outputs.tf                    # Root outputs
├── providers.tf                  # AWS provider config
├── versions.tf                   # Terraform + provider version pins
├── locals.tf                     # Computed names, tags, common values
├── environments/
│   ├── _shared.tfvars            # Shared resource defs (queues, flows, lambdas, ddb, ...)
│   ├── dev.tfvars                # Dev-only flags (overrides _shared)
│   ├── staging.tfvars            # Staging-only flags
│   ├── prod.tfvars               # Prod-only flags
│   ├── dev.backend.hcl
│   ├── staging.backend.hcl
│   └── prod.backend.hcl
├── modules/
│   ├── connect-instance/         # Connect instance + storage config
│   ├── queues/                   # All queues
│   ├── routing-profiles/         # All routing profiles
│   ├── hours-of-operation/       # Business hour schedules
│   ├── contact-flows/            # All contact flows (JSON content)
│   ├── lambda-functions/         # All Lambdas + permissions
│   ├── dynamodb-tables/          # All DynamoDB tables
│   ├── iam/                      # Shared IAM roles & policies
│   ├── s3-storage/               # Recordings, reports buckets
│   ├── lex-bots/                 # Lex V2 bots
│   └── quick-connects/           # Transfer destinations
├── lambda-source/                # Lambda function source code
└── contact-flow-content/         # Contact flow JSON definitions
```

## Usage

### Initialize and deploy

The shared resource shape (queues, routing profiles, contact flows, Lambdas, DynamoDB tables, quick connects, Lex bots, hours of operation) lives in `environments/_shared.tfvars` so every environment provisions the same set of resources. Each per-env file (`dev.tfvars`, `staging.tfvars`, `prod.tfvars`) only contains the environment-specific overrides (instance alias, KMS, retention, billing mode, etc).

```bash
# Install Lambda npm dependencies (one-time)
make lambda-deps

# Initialize backend (per env)
make init ENV=dev

# Plan and apply
make plan  ENV=dev
make apply ENV=dev

# Promote to staging / prod
make plan  ENV=staging && make apply ENV=staging
make plan  ENV=prod    && make apply ENV=prod
```

Equivalent raw terraform commands:

```bash
terraform init -backend-config=environments/dev.backend.hcl

terraform plan \
  -var-file=environments/_shared.tfvars \
  -var-file=environments/dev.tfvars \
  -out=dev.tfplan

terraform apply dev.tfplan
```

### Required variables

| Name           | Description                                              | Example       |
|----------------|----------------------------------------------------------|---------------|
| `environment`  | Environment name — dev, staging, prod                    | `prod`        |
| `aws_region`   | AWS region                                               | `us-east-1`   |
| `project_name` | Project name, used as a prefix everywhere                | `acme-cc`     |
| `instance_alias` | Connect instance alias (must be globally unique)       | `acme-cc-prod`|

### Optional variables

See `variables.tf` for the full list. Key knobs:

- `enable_contact_lens` — turn on Contact Lens analytics (default: true in prod, false in dev)
- `enable_call_recording` — enable call recording to S3 (default: true)
- `dynamodb_billing_mode` — `PAY_PER_REQUEST` for dev, `PROVISIONED` for prod
- `lambda_log_retention_days` — CloudWatch retention (default: 14 in dev, 90 in prod)

## Per-environment differences

| Setting                  | dev               | staging           | prod              |
|--------------------------|-------------------|-------------------|-------------------|
| Connect inbound calls    | enabled           | enabled           | enabled           |
| Connect outbound calls   | disabled          | enabled           | enabled           |
| Contact Lens             | disabled          | enabled           | enabled           |
| DynamoDB billing mode    | PAY_PER_REQUEST   | PAY_PER_REQUEST   | PROVISIONED       |
| DynamoDB PITR            | false             | true              | true              |
| Lambda log retention     | 14 days           | 30 days           | 90 days           |
| S3 versioning            | false             | true              | true              |
| KMS CMK                  | AWS-managed       | Customer-managed  | Customer-managed  |

## Conventions

- Resource names: `${project_name}-${environment}-${resource}` (e.g. `acme-cc-prod-sales-queue`).
- Tags: every resource is tagged with `Project`, `Environment`, `ManagedBy=terraform`, `CostCenter`.
- Secrets: read from AWS Secrets Manager — never hardcoded in tfvars.
- State backend: S3 + DynamoDB locking, configured per-environment via `backend.hcl`.

## Extending

To add a new queue, append to `var.queues` in the appropriate tfvars file — the module iterates with `for_each`.
To add a new Lambda, drop source under `lambda-source/<name>/` and add an entry to `var.lambda_functions`.
To add a new DynamoDB table, add an entry to `var.dynamodb_tables`.
