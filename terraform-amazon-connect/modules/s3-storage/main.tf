###############################################################################
# Optional customer-managed KMS key for S3 encryption
###############################################################################

resource "aws_kms_key" "s3" {
  count = var.use_customer_managed_kms ? 1 : 0

  description             = "${var.name_prefix} - S3 encryption for Connect storage"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3" {
  count         = var.use_customer_managed_kms ? 1 : 0
  name          = "alias/${var.name_prefix}-connect-s3"
  target_key_id = aws_kms_key.s3[0].key_id
}

locals {
  kms_key_arn = var.use_customer_managed_kms ? aws_kms_key.s3[0].arn : null
  sse_algo    = var.use_customer_managed_kms ? "aws:kms" : "AES256"
}

###############################################################################
# Recording bucket — for call recordings
###############################################################################

resource "aws_s3_bucket" "recordings" {
  bucket = "${var.name_prefix}-connect-recordings"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "recordings" {
  bucket = aws_s3_bucket.recordings.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.sse_algo
      kms_master_key_id = local.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "recordings" {
  bucket                  = aws_s3_bucket.recordings.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "recordings" {
  bucket = aws_s3_bucket.recordings.id

  rule {
    id     = "transition-old-recordings"
    status = "Enabled"

    filter {}

    transition {
      days          = var.recording_lifecycle_days
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

###############################################################################
# Report bucket — for scheduled reports, CTR, transcripts
###############################################################################

resource "aws_s3_bucket" "reports" {
  bucket = "${var.name_prefix}-connect-reports"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "reports" {
  bucket = aws_s3_bucket.reports.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.sse_algo
      kms_master_key_id = local.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "reports" {
  bucket                  = aws_s3_bucket.reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id

  rule {
    id     = "expire-old-reports"
    status = "Enabled"

    filter {}

    expiration {
      days = var.report_lifecycle_days
    }
  }
}

###############################################################################
# Exports bucket — for analytics / Athena exports
###############################################################################

resource "aws_s3_bucket" "exports" {
  bucket = "${var.name_prefix}-connect-exports"
  tags   = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "exports" {
  bucket = aws_s3_bucket.exports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.sse_algo
      kms_master_key_id = local.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "exports" {
  bucket                  = aws_s3_bucket.exports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
