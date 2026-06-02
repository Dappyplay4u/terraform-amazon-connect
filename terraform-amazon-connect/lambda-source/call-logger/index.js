/**
 * call-logger
 *
 * Logs supplemental call metadata to DynamoDB at various points in the flow
 * (intent captured, queue entered, agent connected, etc).
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.DDB_TABLE_CALL_RECORDS;

exports.handler = async (event) => {
  const contact = event?.Details?.ContactData || {};
  const params  = event?.Details?.Parameters || {};
  const now     = new Date().toISOString();

  // TTL: keep records for 1 year (in epoch seconds)
  const ttl = Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60;

  const item = {
    contact_id:  contact.ContactId,
    timestamp:   now,
    customer_id: params.customer_id || "unknown",
    event_type:  params.event_type  || "log",
    queue:       params.queue       || "",
    intent:      params.intent      || "",
    channel:     contact.Channel    || "VOICE",
    attributes:  contact.Attributes || {},
    ttl,
  };

  try {
    await ddb.send(new PutCommand({ TableName: TABLE, Item: item }));
    return { logged: "true" };
  } catch (err) {
    console.error("log failed:", err);
    return { logged: "false", error: err.message };
  }
};
