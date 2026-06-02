###############################################################################
# SHARED resource definitions — sourced by every environment.
# Apply with:
#   terraform apply \
#     -var-file=environments/_shared.tfvars \
#     -var-file=environments/<env>.tfvars
#
# Anything that should be IDENTICAL across dev/staging/prod lives here
# (queues, routing profiles, contact flows, lambdas, dynamodb tables).
# Environment-specific tuning (instance alias, flags, KMS, retention) lives
# in the per-env tfvars file.
###############################################################################

###############################################################################
# Hours of operation — 3 schedules
###############################################################################

hours_of_operation = {
  business-hours = {
    description = "Standard business hours, Mon-Fri 9-5 ET"
    time_zone   = "America/New_York"
    config = [
      { day = "MONDAY",    start_hours = 9, start_mins = 0, end_hours = 17, end_mins = 0 },
      { day = "TUESDAY",   start_hours = 9, start_mins = 0, end_hours = 17, end_mins = 0 },
      { day = "WEDNESDAY", start_hours = 9, start_mins = 0, end_hours = 17, end_mins = 0 },
      { day = "THURSDAY",  start_hours = 9, start_mins = 0, end_hours = 17, end_mins = 0 },
      { day = "FRIDAY",    start_hours = 9, start_mins = 0, end_hours = 17, end_mins = 0 },
    ]
  }
  extended-hours = {
    description = "Extended hours, 7 days 7am-10pm"
    time_zone   = "America/New_York"
    config = [
      { day = "MONDAY",    start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
      { day = "TUESDAY",   start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
      { day = "WEDNESDAY", start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
      { day = "THURSDAY",  start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
      { day = "FRIDAY",    start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
      { day = "SATURDAY",  start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
      { day = "SUNDAY",    start_hours = 7, start_mins = 0, end_hours = 22, end_mins = 0 },
    ]
  }
  "24x7" = {
    description = "Always available"
    time_zone   = "America/New_York"
    config = [
      { day = "MONDAY",    start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
      { day = "TUESDAY",   start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
      { day = "WEDNESDAY", start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
      { day = "THURSDAY",  start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
      { day = "FRIDAY",    start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
      { day = "SATURDAY",  start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
      { day = "SUNDAY",    start_hours = 0, start_mins = 0, end_hours = 23, end_mins = 59 },
    ]
  }
}

###############################################################################
# Queues — 8 total
###############################################################################

queues = {
  sales = {
    description        = "Inbound sales inquiries"
    hours_of_operation = "extended-hours"
    max_contacts       = 50
  }
  support-tier1 = {
    description        = "First-line customer support"
    hours_of_operation = "extended-hours"
    max_contacts       = 100
  }
  support-tier2 = {
    description        = "Escalated support — senior agents"
    hours_of_operation = "business-hours"
    max_contacts       = 30
  }
  billing = {
    description        = "Billing and account inquiries"
    hours_of_operation = "business-hours"
    max_contacts       = 40
  }
  technical = {
    description        = "Technical troubleshooting"
    hours_of_operation = "extended-hours"
    max_contacts       = 50
  }
  vip = {
    description        = "VIP / premium customer queue"
    hours_of_operation = "24x7"
    max_contacts       = 20
  }
  callback = {
    description        = "Scheduled callbacks"
    hours_of_operation = "business-hours"
    max_contacts       = 100
  }
  overflow = {
    description        = "Overflow queue when other queues are at capacity"
    hours_of_operation = "extended-hours"
    max_contacts       = 200
  }
}

###############################################################################
# Routing profiles — 5 total
###############################################################################

routing_profiles = {
  sales-agents = {
    description            = "Sales team — handles sales + overflow"
    default_outbound_queue = "sales"
    media_concurrencies = [
      { channel = "VOICE", concurrency = 1 },
      { channel = "CHAT",  concurrency = 3 },
    ]
    queue_configs = [
      { queue_key = "sales",    channel = "VOICE", priority = 1, delay = 0 },
      { queue_key = "sales",    channel = "CHAT",  priority = 1, delay = 0 },
      { queue_key = "overflow", channel = "VOICE", priority = 5, delay = 30 },
    ]
  }
  support-agents = {
    description            = "Tier-1 support agents"
    default_outbound_queue = "support-tier1"
    media_concurrencies = [
      { channel = "VOICE", concurrency = 1 },
      { channel = "CHAT",  concurrency = 4 },
    ]
    queue_configs = [
      { queue_key = "support-tier1", channel = "VOICE", priority = 1, delay = 0 },
      { queue_key = "support-tier1", channel = "CHAT",  priority = 1, delay = 0 },
      { queue_key = "callback",      channel = "VOICE", priority = 3, delay = 10 },
      { queue_key = "overflow",      channel = "VOICE", priority = 5, delay = 30 },
    ]
  }
  senior-support-agents = {
    description            = "Tier-2 / senior support"
    default_outbound_queue = "support-tier2"
    media_concurrencies = [
      { channel = "VOICE", concurrency = 1 },
    ]
    queue_configs = [
      { queue_key = "support-tier2", channel = "VOICE", priority = 1, delay = 0 },
      { queue_key = "support-tier1", channel = "VOICE", priority = 3, delay = 60 },
    ]
  }
  billing-agents = {
    description            = "Billing team"
    default_outbound_queue = "billing"
    media_concurrencies = [
      { channel = "VOICE", concurrency = 1 },
      { channel = "CHAT",  concurrency = 2 },
    ]
    queue_configs = [
      { queue_key = "billing", channel = "VOICE", priority = 1, delay = 0 },
      { queue_key = "billing", channel = "CHAT",  priority = 1, delay = 0 },
    ]
  }
  vip-agents = {
    description            = "VIP-only agents"
    default_outbound_queue = "vip"
    media_concurrencies = [
      { channel = "VOICE", concurrency = 1 },
      { channel = "CHAT",  concurrency = 2 },
    ]
    queue_configs = [
      { queue_key = "vip", channel = "VOICE", priority = 1, delay = 0 },
      { queue_key = "vip", channel = "CHAT",  priority = 1, delay = 0 },
    ]
  }
}

###############################################################################
# Contact flows — 10 total
###############################################################################

contact_flows = {
  inbound-main = {
    description  = "Main inbound entry point — auth, intent capture, routing"
    type         = "CONTACT_FLOW"
    content_file = "inbound-main.json"
  }
  inbound-auth = {
    description  = "Customer authentication subflow"
    type         = "CONTACT_FLOW"
    content_file = "inbound-auth.json"
  }
  queue-customer = {
    description  = "Customer queue experience"
    type         = "CUSTOMER_QUEUE"
    content_file = "queue-customer.json"
  }
  customer-hold = {
    description  = "Customer hold experience"
    type         = "CUSTOMER_HOLD"
    content_file = "customer-hold.json"
  }
  customer-whisper = {
    description  = "Played to customer right before connecting"
    type         = "CUSTOMER_WHISPER"
    content_file = "customer-whisper.json"
  }
  agent-whisper = {
    description  = "Whisper played to agent"
    type         = "AGENT_WHISPER"
    content_file = "agent-whisper.json"
  }
  outbound-whisper = {
    description  = "Outbound call whisper"
    type         = "OUTBOUND_WHISPER"
    content_file = "outbound-whisper.json"
  }
  transfer = {
    description  = "Agent-to-agent transfer flow"
    type         = "QUEUE_TRANSFER"
    content_file = "transfer.json"
  }
  callback = {
    description  = "Scheduled callback handler"
    type         = "CONTACT_FLOW"
    content_file = "callback.json"
  }
  post-call-survey = {
    description  = "Post-call satisfaction survey"
    type         = "CONTACT_FLOW"
    content_file = "post-call-survey.json"
  }
}

###############################################################################
# DynamoDB tables — 6 total
###############################################################################

dynamodb_tables = {
  customers = {
    hash_key = "customer_id"
    attributes = [
      { name = "customer_id", type = "S" },
      { name = "phone",       type = "S" },
    ]
    global_secondary_indexes = [
      { name = "phone-index", hash_key = "phone", projection_type = "ALL" },
    ]
  }
  call-records = {
    hash_key  = "contact_id"
    range_key = "timestamp"
    attributes = [
      { name = "contact_id",  type = "S" },
      { name = "timestamp",   type = "S" },
      { name = "customer_id", type = "S" },
    ]
    global_secondary_indexes = [
      { name = "by-customer", hash_key = "customer_id", range_key = "timestamp", projection_type = "ALL" },
    ]
    ttl_attribute  = "ttl"
    stream_enabled = true
  }
  callback-requests = {
    hash_key = "callback_id"
    attributes = [
      { name = "callback_id",  type = "S" },
      { name = "status",       type = "S" },
      { name = "scheduled_at", type = "S" },
    ]
    global_secondary_indexes = [
      { name = "by-status", hash_key = "status", range_key = "scheduled_at", projection_type = "ALL" },
    ]
  }
  agent-stats = {
    hash_key  = "agent_id"
    range_key = "date"
    attributes = [
      { name = "agent_id", type = "S" },
      { name = "date",     type = "S" },
    ]
  }
  survey-responses = {
    hash_key = "contact_id"
    attributes = [
      { name = "contact_id", type = "S" },
    ]
    ttl_attribute = "ttl"
  }
  configuration = {
    hash_key = "config_key"
    attributes = [
      { name = "config_key", type = "S" },
    ]
  }
}

###############################################################################
# Lambda functions — 7 total
###############################################################################

lambda_functions = {
  customer-lookup = {
    description     = "Look up customer by phone number, return profile attributes"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 8
    memory_size     = 256
    source_dir      = "customer-lookup"
    dynamodb_access = ["customers", "call-records"]
  }
  call-logger = {
    description     = "Persist call metadata and CTR-supplemental data"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 10
    memory_size     = 256
    source_dir      = "call-logger"
    dynamodb_access = ["call-records"]
  }
  callback-scheduler = {
    description     = "Schedule callback requests"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 10
    memory_size     = 256
    source_dir      = "callback-scheduler"
    dynamodb_access = ["callback-requests", "customers"]
  }
  business-hours-check = {
    description     = "Determine open/closed/holiday status"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 5
    memory_size     = 128
    source_dir      = "business-hours-check"
    dynamodb_access = ["configuration"]
  }
  crm-integration = {
    description     = "Fetch case/ticket info from external CRM"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 15
    memory_size     = 512
    source_dir      = "crm-integration"
    dynamodb_access = ["customers"]
    environment = {
      CRM_API_BASE = "https://crm.example.com/api"
    }
  }
  post-call-survey = {
    description     = "Persist post-call survey responses"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 10
    memory_size     = 256
    source_dir      = "post-call-survey"
    dynamodb_access = ["survey-responses"]
  }
  agent-screen-pop = {
    description     = "Build screen-pop payload for agent CCP"
    handler         = "index.handler"
    runtime         = "nodejs20.x"
    timeout         = 8
    memory_size     = 256
    source_dir      = "agent-screen-pop"
    dynamodb_access = ["customers", "call-records"]
  }
}

###############################################################################
# Quick connects — 3 transfer destinations
###############################################################################

quick_connects = {
  supervisor-transfer = {
    description      = "Transfer to supervisor queue"
    type             = "QUEUE"
    queue_key        = "support-tier2"
    contact_flow_key = "transfer"
  }
  billing-transfer = {
    description      = "Transfer to billing"
    type             = "QUEUE"
    queue_key        = "billing"
    contact_flow_key = "transfer"
  }
  technical-transfer = {
    description      = "Transfer to technical"
    type             = "QUEUE"
    queue_key        = "technical"
    contact_flow_key = "transfer"
  }
}