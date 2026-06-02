/**
 * post-call-survey
 *
 * Persists post-call survey responses (CSAT score + optional comment).
 * Called from the post-call-survey contact flow after collecting DTMF input.
 */
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.DDB_TABLE_SURVEY_RESPONSES;

exports.handler = async (event) => {
  const contact = event?.Details?.ContactData || {};
  const params  = event?.Details?.Parameters || {};

  const score = parseInt(params.csat_score, 10);
  if (Number.isNaN(score) || score < 1 || score > 5) {
    return { recorded: "false", reason: "invalid_score" };
  }

  // TTL: keep surveys for 2 years
  const ttl = Math.floor(Date.now() / 1000) + 2 * 365 * 24 * 60 * 60;

  const item = {
    contact_id:    contact.ContactId,
    csat_score:    score,
    nps_score:     params.nps_score ? parseInt(params.nps_score, 10) : null,
    customer_id:   params.customer_id || "unknown",
    agent_id:      params.agent_id || "",
    queue:         params.queue || "",
    submitted_at:  new Date().toISOString(),
    ttl,
  };

  try {
    await ddb.send(new PutCommand({ TableName: TABLE, Item: item }));
    return { recorded: "true", score: String(score) };
  } catch (err) {
    console.error("survey record failed:", err);
    return { recorded: "false", error: err.message };
  }
};
