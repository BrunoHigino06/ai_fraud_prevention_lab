import boto3
from boto3.dynamodb.conditions import Key
import sys
from awsglue.utils import getResolvedOptions
import logging
import json

# Call dynamodb
dynamodb = boto3.resource("dynamodb")
user_table = dynamodb.Table("user_table")

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

# Call lambda client
lambda_client = boto3.client('lambda')

args = getResolvedOptions(
    sys.argv,
    [
        "timestamp",
        "name",
        "value",
        "location"
    ]
)

timestamp = args["timestamp"]
user_name = args["name"]
value = args["value"]
location = args["location"]
function_name = "fraud_detection"
invocation = "RequestResponse"


def get_id(user_name):
    response = user_table.query(
        KeyConditionExpression=Key("user_name").eq(user_name),
    )
    items = response.get("Items", [])

    if not items:
        logger.info(f"User ID: {user_name} not found")
        return None

    return items[0]["user_id"]

user_id = get_id(user_name)

logger.info(f"Use UserID {user_id} for user {user_name}")


def normalize_data(timestamp, user_id, value, location):
    normalized_data = {
        "timestamp": timestamp,
        "user_id": user_id,
        "value": value,
        "location": location
    }
    return normalized_data

payload = normalize_data(timestamp, user_id, value, location)

logger.info(f"Created payload {payload}")

def agent_backend(function_name, invocation, payload):

    response = lambda_client.invoke(
        FunctionName = function_name,
        InvocationType = invocation,
        payload = json.dumps(payload)
    )
    return response

logger.info(f"Call Agent backend lambda {function_name}, {invocation} to process the payload {payload}")
agent_backend(function_name, invocation, payload)
