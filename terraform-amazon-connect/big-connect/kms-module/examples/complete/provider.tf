###############################################################################
# KMS Complete Example — Provider
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  # ── S3 backend (recommended for teams) ──────────────────────────────────────
  # backend "s3" {
  #   bucket         = "<your-tf-state-bucket>"
  #   key            = "connect/kms/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region
}
