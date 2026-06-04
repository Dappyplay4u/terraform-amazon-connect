###############################################################################
# Kinesis Module — Main
# Two Kinesis Data Streams: contact_trace_records | media_streams
# Optional: Firehose delivery of CTR records → S3
# Optional: CloudWatch iterator-age alarms
###############################################################################

# ── Kinesis Data Streams ──────────────────────────────────────────────────────

resource "aws_kinesis_stream" "this" {
  for_each = local.stream_definitions

  name             = "${local.name_prefix}-connect-${each.value.suffix}"
  retention_period = var.retention_period_hours

  stream_mode_details {
    stream_mode = var.stream_mode
  }

  shard_count = var.stream_mode == "PROVISIONED" ? var.shard_count : null

  encryption_type = "KMS"
  kms_key_id      = var.kms_key_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-connect-${each.value.suffix}"
  })
}

# ── IAM Role for Kinesis Firehose ─────────────────────────────────────────────

resource "aws_iam_role" "firehose" {
  count = var.enable_firehose_ctr ? 1 : 0

  name = "${local.name_prefix}-connect-firehose-role"
  path = "/connect/"

  description = "IAM role for Kinesis Firehose CTR delivery"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = { "sts:ExternalId" = local.account_id }
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-connect-firehose-role"
  })
}

resource "aws_iam_role_policy" "firehose" {
  count = var.enable_firehose_ctr ? 1 : 0

  name = "${local.name_prefix}-connect-firehose-policy"
  role = aws_iam_role.firehose[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
        ]
        Resource = [
          var.ctr_s3_bucket_arn,
          "${var.ctr_s3_bucket_arn}/*",
        ]
      },
      {
        Sid      = "KMSAccess"
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "KinesisSourceAccess"
        Effect = "Allow"
        Action = [
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:DescribeStream",
          "kinesis:ListShards",
          "kinesis:SubscribeToShard",
        ]
        Resource = [aws_kinesis_stream.this["contact_trace_records"].arn]
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents"]
        Resource = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:*"]
      },
    ]
  })
}

# ── Kinesis Firehose: CTR → S3 ────────────────────────────────────────────────

resource "aws_kinesis_firehose_delivery_stream" "ctr" {
  count = var.enable_firehose_ctr ? 1 : 0

  name        = "${local.name_prefix}-connect-ctr-firehose"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.this["contact_trace_records"].arn
    role_arn           = aws_iam_role.firehose[0].arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose[0].arn
    bucket_arn         = var.ctr_s3_bucket_arn
    buffering_size     = var.firehose_buffering_size_mb
    buffering_interval = var.firehose_buffering_interval_seconds
    compression_format = "GZIP"

    # Hive-compatible partitioning for Athena/Glue
    prefix              = "ctr/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "ctr-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    kms_key_arn = var.kms_key_arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${local.name_prefix}-connect-ctr"
      log_stream_name = "S3Delivery"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-connect-ctr-firehose"
  })
}

# ── CloudWatch Alarms: iterator age ──────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "iterator_age" {
  for_each = var.enable_cloudwatch_alarms ? local.stream_definitions : {}

  alarm_name          = "${local.name_prefix}-connect-${each.value.suffix}-iterator-age-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "GetRecords.IteratorAgeMilliseconds"
  namespace           = "AWS/Kinesis"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.iterator_age_alarm_threshold_ms
  alarm_description   = "Iterator age too high on ${each.value.description}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    StreamName = aws_kinesis_stream.this[each.key].name
  }

  alarm_actions = var.alarm_sns_topic_arns
  ok_actions    = var.alarm_sns_topic_arns

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-connect-${each.value.suffix}-iterator-age-high"
  })
}
