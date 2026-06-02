###############################################################################
# 1. S3 storage — must exist before Connect instance so call recordings can go there
###############################################################################

module "s3_storage" {
  source = "./modules/s3-storage"

  name_prefix             = local.name_prefix
  enable_versioning       = var.enable_s3_versioning
  recording_lifecycle_days = var.s3_lifecycle_recording_days
  report_lifecycle_days   = var.s3_lifecycle_report_days
  use_customer_managed_kms = var.use_customer_managed_kms
  tags                    = local.common_tags
}

###############################################################################
# 2. DynamoDB tables — needed before Lambdas (which read them)
###############################################################################

module "dynamodb_tables" {
  source = "./modules/dynamodb-tables"

  name_prefix    = local.name_prefix
  tables         = var.dynamodb_tables
  billing_mode   = var.dynamodb_billing_mode
  enable_pitr    = local.is_prod
  tags           = local.common_tags
}

###############################################################################
# 3. IAM — shared roles & policies for Connect, Lambdas
###############################################################################

module "iam" {
  source = "./modules/iam"

  name_prefix          = local.name_prefix
  dynamodb_table_arns  = module.dynamodb_tables.table_arns
  s3_recording_bucket_arn = module.s3_storage.recording_bucket_arn
  s3_report_bucket_arn = module.s3_storage.report_bucket_arn
  tags                 = local.common_tags
}

###############################################################################
# 4. Lambda functions — provisioned before Connect so flows can associate them
###############################################################################

module "lambda_functions" {
  source = "./modules/lambda-functions"

  name_prefix          = local.name_prefix
  functions            = var.lambda_functions
  source_root          = "${path.module}/lambda-source"
  execution_role_arn   = module.iam.lambda_execution_role_arn
  dynamodb_table_names = module.dynamodb_tables.table_names
  log_retention_days   = var.lambda_log_retention_days
  tags                 = local.common_tags
}

###############################################################################
# 5. Connect instance
###############################################################################

module "connect_instance" {
  source = "./modules/connect-instance"

  instance_alias            = var.instance_alias
  identity_management_type  = var.identity_management_type
  inbound_calls_enabled     = var.inbound_calls_enabled
  outbound_calls_enabled    = var.outbound_calls_enabled
  enable_contact_lens       = var.enable_contact_lens
  enable_auto_resolve_best_voices = var.enable_auto_resolve_best_voices
  enable_contactflow_logs   = var.enable_contactflow_logs
  enable_call_recording     = var.enable_call_recording
  call_recording_bucket     = module.s3_storage.recording_bucket_name
  call_recording_prefix     = "connect/${local.name_prefix}/recordings"
  reports_bucket            = module.s3_storage.report_bucket_name
  reports_prefix            = "connect/${local.name_prefix}/reports"
}

###############################################################################
# 6. Hours of operation — required before queues
###############################################################################

module "hours_of_operation" {
  source = "./modules/hours-of-operation"

  instance_id        = module.connect_instance.instance_id
  hours_of_operation = var.hours_of_operation
}

###############################################################################
# 7. Queues — depend on hours of operation
###############################################################################

module "queues" {
  source = "./modules/queues"

  instance_id              = module.connect_instance.instance_id
  name_prefix              = local.name_prefix
  queues                   = var.queues
  hours_of_operation_ids   = module.hours_of_operation.hours_ids
}

###############################################################################
# 8. Quick connects — depend on queues
###############################################################################

module "quick_connects" {
  source = "./modules/quick-connects"

  instance_id      = module.connect_instance.instance_id
  name_prefix      = local.name_prefix
  quick_connects   = var.quick_connects
  queue_ids        = module.queues.queue_ids
  contact_flow_ids = module.contact_flows.flow_ids
}

###############################################################################
# 9. Routing profiles — depend on queues
###############################################################################

module "routing_profiles" {
  source = "./modules/routing-profiles"

  instance_id      = module.connect_instance.instance_id
  name_prefix      = local.name_prefix
  routing_profiles = var.routing_profiles
  queue_ids        = module.queues.queue_ids
}

###############################################################################
# 10. Lambda associations — attach Lambdas to Connect instance
###############################################################################

resource "aws_connect_lambda_function_association" "this" {
  for_each = {
    for k, v in var.lambda_functions : k => v
    if v.associate_with_connect
  }

  instance_id  = module.connect_instance.instance_id
  function_arn = module.lambda_functions.function_arns[each.key]
}


###############################################################################
# 11. Contact flows — depend on Lambdas, queues, Lex
###############################################################################

module "contact_flows" {
  source = "./modules/contact-flows"

  instance_id       = module.connect_instance.instance_id
  name_prefix       = local.name_prefix
  contact_flows     = var.contact_flows
  content_root      = "${path.module}/contact-flow-content"

  # Substitution vars — flow JSON can reference these as ${var_name}
  substitutions = merge(
    {
      for k, arn in module.lambda_functions.function_arns :
      "lambda_${replace(k, "-", "_")}_arn" => arn
    },
    {
      for k, id in module.queues.queue_ids :
      "queue_${replace(k, "-", "_")}_id" => id
    },
  )
}
