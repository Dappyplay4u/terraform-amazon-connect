/**
 * agent-screen-pop
 *
 * Builds the payload for the agent CCP screen-pop. Called just before
 * the call is routed to an agent — returns a compact set of attributes
 * (customer name, last 3 contact reasons, open case ID) that the
 * CCP/agent app reads from contact attributes.
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, QueryCommand } = require("@aws-sdk/lib-dynamodb");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const CUSTOMERS_TABLE    = process.env.DDB_TABLE_CUSTOMERS;
const CALL_RECORDS_TABLE = process.env.DDB_TABLE_CALL_RECORDS;

exports.handler = async (event) => {
  const params = event?.Details?.Parameters || {};
  const customerId = params.customer_id;

  if (!customerId || customerId === "unknown") {
    return { pop_ready: "false", reason: "anonymous_caller" };
  }

  // Fetch customer profile + last 3 contacts in parallel
  const [profileRes, historyRes] = await Promise.all([
    ddb.send(new GetCommand({
      TableName: CUSTOMERS_TABLE,
      Key: { customer_id: customerId },
    })),
    ddb.send(new QueryCommand({
      TableName:     CALL_RECORDS_TABLE,
      IndexName:     "by-customer",
      KeyConditionExpression: "customer_id = :cid",
      ExpressionAttributeValues: { ":cid": customerId },
      ScanIndexForward: false,
      Limit: 3,
    })),
  ]);

  const profile = profileRes.Item || {};
  const history = historyRes.Items || [];

  const recentIntents = history
    .map(h => h.intent)
    .filter(Boolean)
    .join("|");

  return {
    pop_ready:     "true",
    display_name:  `${profile.first_name || ""} ${profile.last_name || ""}`.trim() || "Unknown",
    account_tier:  profile.account_tier || "standard",
    customer_since: profile.customer_since || "",
    last_intents:  recentIntents,
    open_case_id:  profile.open_case_id || "",
    notes:         (profile.agent_notes || "").slice(0, 240),
  };
};
