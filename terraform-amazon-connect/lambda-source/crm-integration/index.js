/**
 * crm-integration
 *
 * Calls the external CRM to fetch the customer's most recent open case.
 * The base URL is injected via env var; the API key is read from
 * Secrets Manager (recommended) but for brevity is shown via env var here.
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const CUSTOMERS_TABLE = process.env.DDB_TABLE_CUSTOMERS;
const CRM_BASE        = process.env.CRM_API_BASE;
const CRM_API_KEY     = process.env.CRM_API_KEY || ""; // prefer secrets manager

exports.handler = async (event) => {
  const params = event?.Details?.Parameters || {};
  const customerId = params.customer_id;

  if (!customerId || customerId === "unknown") {
    return { has_case: "false", reason: "no_customer_id" };
  }

  // Look up the CRM external ID stored in our customers table
  let externalId;
  try {
    const res = await ddb.send(new GetCommand({
      TableName: CUSTOMERS_TABLE,
      Key: { customer_id: customerId },
    }));
    externalId = res.Item?.crm_external_id;
  } catch (err) {
    console.error("customer lookup failed:", err);
    return { has_case: "false", reason: "ddb_error" };
  }

  if (!externalId) {
    return { has_case: "false", reason: "no_crm_link" };
  }

  // Call CRM
  try {
    const url = `${CRM_BASE}/customers/${encodeURIComponent(externalId)}/cases?status=open&limit=1`;
    const resp = await fetch(url, {
      headers: {
        "Authorization": `Bearer ${CRM_API_KEY}`,
        "Accept":        "application/json",
      },
    });

    if (!resp.ok) {
      return { has_case: "false", reason: `crm_${resp.status}` };
    }

    const data = await resp.json();
    const cases = data?.cases || [];

    if (cases.length === 0) {
      return { has_case: "false" };
    }

    const c = cases[0];
    return {
      has_case:    "true",
      case_id:     c.id || "",
      case_subject: (c.subject || "").slice(0, 200),
      case_priority: c.priority || "normal",
      case_age_days: String(c.age_days || 0),
    };
  } catch (err) {
    console.error("crm call failed:", err);
    return { has_case: "false", reason: "crm_error" };
  }
};
