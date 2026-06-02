locals {
  # Build DynamoDB env vars for each function based on dynamodb_access list
  function_env_vars = {
    for fk, fv in var.functions : fk => merge(
      fv.environment,
      {
        for tk in fv.dynamodb_access :
        "DDB_TABLE_${upper(replace(tk, "-", "_"))}" => var.dynamodb_table_names[tk]
      },
    )
  }
}

# Package each Lambda source directory into a zip
data "archive_file" "this" {
  for_each = var.functions

  type        = "zip"
  source_dir  = "${var.source_root}/${each.value.source_dir}"
  output_path = "${path.module}/.builds/${each.key}.zip"
}

resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name    = "${var.name_prefix}-${each.key}"
  description      = each.value.description
  role             = var.execution_role_arn
  handler          = each.value.handler
  runtime          = each.value.runtime
  timeout          = each.value.timeout
  memory_size      = each.value.memory_size
  filename         = data.archive_file.this[each.key].output_path
  source_code_hash = data.archive_file.this[each.key].output_base64sha256

  environment {
    variables = local.function_env_vars[each.key]
  }

  tracing_config {
    mode = "Active"
  }

  tags = merge(var.tags, { LambdaName = each.key })
}

# CloudWatch log group per function with explicit retention
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.functions

  name              = "/aws/lambda/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Allow Amazon Connect to invoke each Lambda
resource "aws_lambda_permission" "connect_invoke" {
  for_each = {
    for k, v in var.functions : k => v if v.associate_with_connect
  }

  statement_id  = "AllowConnectInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "connect.amazonaws.com"
}
