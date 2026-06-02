/**
 * callback-scheduler
 *
 * Persists a callback request from a contact flow. The flow collects the
 * callback number + preferred time, then invokes this Lambda. A separate
 * worker (out of scope) reads callback-requests and triggers
 * StartOutboundVoiceContact when due.
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const crypto = require("crypto");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.DDB_TABLE_CALLBACK_REQUESTS;

exports.handler = async (event) => {
  const contact = event?.Details?.ContactData || {};
  const params  = event?.Details?.Parameters || {};

  const phone = params.callback_number
    || contact.CustomerEndpoint?.Address;

  if (!phone) {
    return { scheduled: "false", reason: "no_phone" };
  }

  const callbackId = crypto.randomUUID();
  const scheduledAt = params.scheduled_at || new Date(Date.now() + 30 * 60 * 1000).toISOString();

  const item = {
    callback_id:    callbackId,
    status:         "pending",
    scheduled_at:   scheduledAt,
    phone,
    customer_id:    params.customer_id || "unknown",
    original_contact_id: contact.ContactId,
    queue:          params.queue || "callback",
    intent:         params.intent || "",
    created_at:     new Date().toISOString(),
    attempts:       0,
  };

  try {
    await ddb.send(new PutCommand({ TableName: TABLE, Item: item }));
    return {
      scheduled:   "true",
      callback_id: callbackId,
      scheduled_at: scheduledAt,
    };
  } catch (err) {
    console.error("schedule failed:", err);
    return { scheduled: "false", error: err.message };
  }
};
