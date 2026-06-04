###############################################################################
# S3 Module — Main
# Three Connect storage buckets: call_recordings | scheduled_reports | chat_transcripts
# + optional access-log bucket
# All buckets: versioned, KMS-encrypted, TLS-enforced, public-access-blocked
###############################################################################

# ── S3 Buckets ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "this" {
  for_each = local.bucket_definitions

  bucket        = "${local.name_prefix}-${each.value.suffix}"
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.value.suffix}"
  })
}

# ── Versioning ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.bucket_definitions

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── KMS Encryption ────────────────────────────────────────────────────────────

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = local.bucket_definitions

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

# ── Block All Public Access ───────────────────────────────────────────────────

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = local.bucket_definitions

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Lifecycle Rules ───────────────────────────────────────────────────────────

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = local.bucket_definitions

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    id     = "connect-storage-lifecycle"
    status = "Enabled"

    transition {
      days          = var.lifecycle_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.lifecycle_glacier_transition_days
      storage_class = "GLACIER"
    }

    dynamic "expiration" {
      for_each = var.lifecycle_expiration_days > 0 ? [1] : []
      content {
        days = var.lifecycle_expiration_days
      }
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# ── Bucket Policies: TLS enforcement + Connect service access ─────────────────

data "aws_iam_policy_document" "bucket_policy" {
  for_each = local.bucket_definitions

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this[each.key].arn,
      "${aws_s3_bucket.this[each.key].arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowConnectService"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["connect.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this[each.key].arn,
      "${aws_s3_bucket.this[each.key].arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = local.bucket_definitions

  bucket = aws_s3_bucket.this[each.key].id
  policy = data.aws_iam_policy_document.bucket_policy[each.key].json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# ── Access Logging Bucket (optional) ─────────────────────────────────────────

resource "aws_s3_bucket" "access_logs" {
  count = var.enable_access_logging ? 1 : 0

  bucket        = "${local.name_prefix}-connect-s3-access-logs"
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-connect-s3-access-logs"
  })
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count = var.enable_access_logging ? 1 : 0

  bucket                  = aws_s3_bucket.access_logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count = var.enable_access_logging ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "this" {
  for_each = var.enable_access_logging ? local.bucket_definitions : {}

  bucket        = aws_s3_bucket.this[each.key].id
  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "${each.key}/"
}
