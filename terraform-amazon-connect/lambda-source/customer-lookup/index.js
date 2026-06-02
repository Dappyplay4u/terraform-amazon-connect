/**
 * customer-lookup
 *
 * Invoked from a contact flow Lambda block. Looks up a customer by inbound
 * phone number (Customer Profiles fallback) and returns attributes that
 * Connect will merge into the contact attributes for use downstream.
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, QueryCommand } = require("@aws-sdk/lib-dynamodb");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const CUSTOMERS_TABLE = process.env.DDB_TABLE_CUSTOMERS;

exports.handler = async (event) => {
  console.log("event:", JSON.stringify(event));

  const phone = event?.Details?.ContactData?.CustomerEndpoint?.Address;
  if (!phone) {
    return { found: "false", reason: "no_phone" };
  }

  try {
    const res = await ddb.send(new QueryCommand({
      TableName: CUSTOMERS_TABLE,
      IndexName: "phone-index",
      KeyConditionExpression: "phone = :p",
      ExpressionAttributeValues: { ":p": phone },
      Limit: 1,
    }));

    if (!res.Items || res.Items.length === 0) {
      return { found: "false", phone };
    }

    const c = res.Items[0];
    return {
      found:         "true",
      customer_id:   c.customer_id,
      first_name:    c.first_name || "",
      last_name:     c.last_name || "",
      account_tier:  c.account_tier || "standard",
      preferred_lang: c.preferred_lang || "en_US",
      is_vip:        String(c.account_tier === "vip"),
    };
  } catch (err) {
    console.error("lookup failed:", err);
    return { found: "false", reason: "error", error: err.message };
  }
};
