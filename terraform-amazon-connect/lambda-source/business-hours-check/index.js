/**
 * business-hours-check
 *
 * Returns open/closed/holiday status. Connect already has a
 * "Check hours of operation" block, but this Lambda lets us layer
 * holiday/blackout overrides from the configuration table.
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.DDB_TABLE_CONFIGURATION;

exports.handler = async (event) => {
  const params = event?.Details?.Parameters || {};
  const today  = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

  // Check for holiday override
  try {
    const res = await ddb.send(new GetCommand({
      TableName: TABLE,
      Key: { config_key: `holiday#${today}` },
    }));

    if (res.Item) {
      return {
        status:  "holiday",
        message: res.Item.message || "We are closed for the holiday.",
        reroute_to: res.Item.reroute_to || "voicemail",
      };
    }
  } catch (err) {
    console.error("config lookup failed:", err);
    // Fall through — treat as not a holiday
  }

  // Check explicit blackout window
  const queueKey = params.queue || "default";
  try {
    const res = await ddb.send(new GetCommand({
      TableName: TABLE,
      Key: { config_key: `blackout#${queueKey}` },
    }));
    if (res.Item && res.Item.active === true) {
      return {
        status:  "blackout",
        message: res.Item.message || "This service is temporarily unavailable.",
      };
    }
  } catch (err) {
    console.error("blackout lookup failed:", err);
  }

  // Default: open (the actual hours-of-operation check happens in the flow itself)
  return { status: "open" };
};
