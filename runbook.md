## Bootstrap the state backend. In Git Bash, from any directory, run this block. It creates the S3 state buckets and DynamoDB lock tables for all three environments in one go:

--bash-- 

PROJECT=acme-cc
REGION=us-east-1

for ENV in dev staging prod; do
  echo "=== Bootstrapping ${ENV} ==="

  # State bucket
  aws s3api create-bucket \
    --bucket "${PROJECT}-terraform-state-${ENV}" \
    --region "${REGION}"

  aws s3api put-bucket-versioning \
    --bucket "${PROJECT}-terraform-state-${ENV}" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "${PROJECT}-terraform-state-${ENV}" \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

  aws s3api put-public-access-block \
    --bucket "${PROJECT}-terraform-state-${ENV}" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,BlockPublicPolicy=true,IgnorePublicAcls=true,RestrictPublicBuckets=true"

  # Lock table
  aws dynamodb create-table \
    --table-name "${PROJECT}-terraform-locks-${ENV}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"

  echo "=== ${ENV} bootstrap complete ==="
  echo ""
done

## verify

aws s3api list-buckets --query 'Buckets[?contains(Name, `acme-cc-terraform`)].Name'
aws dynamodb list-tables --query 'TableNames[?contains(@, `acme-cc-terraform`)]'

## Install Lambda dependencies
## The Lambda source code uses the AWS SDK, which has to be packaged with each function. Run:

make lambda-deps

## Verify it worked — every Lambda dir should now have a node_modules/:

ls lambda-source/customer-lookup/

## Initialize Terraform
## From the extracted module directory (where main.tf lives), run:

make init ENV=dev

## or without make:

terraform init -reconfigure -backend-config=environments/dev.backend.hcl

## Plan the deployment
## bash

make plan ENV=dev

## Or raw:
## bash

terraform plan \
  -var-file=environments/_shared.tfvars \
  -var-file=environments/dev.tfvars \
  -out=dev.tfplan

## Apply
## bash

make apply ENV=dev

## Or raw:

terraform apply dev.tfplan
