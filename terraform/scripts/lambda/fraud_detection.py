import json, boto3, logging, uuid,os
from boto3.dynamodb.conditions import Key

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

# Set up bedrock
bedrock_client = boto3.client('bedrock-agent-runtime')

# Set up dynamodb
dynamodb            = boto3.resource("dynamodb")
transaction_table   = dynamodb.Table("transaction_table")
fraud_results_table = dynamodb.Table("fraud_results_table")

agent_id            = os.getenv('AGENT_ID')
agent_alias_id      = os.getenv('AGENT_ALIAS_ID')

def last_transactions(user_id):

    logger.info(f'Getting the last 10 transactions of the user {user_id}')
    response = transaction_table.query(
        KeyConditionExpression=Key("user_id").eq(user_id),
        Limit=10
    )

    logger.info(f'The transactions that will be used by the analisys will be: {response}')
    return response

def invoke_agent(agent_id, agent_alias_id, prompt):

    response = bedrock_client.invoke_agent(
        agentId      = agent_id,
        agentAliasId = agent_alias_id,
        sessionId    =  str(uuid.uuid4()),
        inputText    = prompt
    )

    agent_text = ""
    for event in response.get("completion", []):
        chunk = event.get("chunk")
        if chunk:
            agent_text += chunk["bytes"].decode("utf-8")

    analysis = json.loads(agent_text)

    return analysis

def handler(event, context):

    # Log the received event for debugging purposes
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get the body of the request, which can be either a JSON string or a dictionary
    if "body" in event:
        body = json.loads(event["body"])
    else:
        body = event

    # Log the extracted parameters for debugging purposes
    logger.info(f"Extracted parameters: {json.dumps(body)}")

    # Extract parameters from the body
    timestamp = body.get("timestamp")
    user_id   = body.get("user_id")
    value     = body.get("value")
    location  = body.get("location")

    get_transactions = last_transactions(user_id)

    current_transaction = {
        "timestamp": timestamp,
        "user_id": user_id,
        "value": value,
        "location": location
    }

    with open("prompts/fraud_analysis.md", "r", encoding="utf-8") as f:
        template = f.read()

    prompt = template.format(
        current_transaction=json.dumps(current_transaction),
        last_transactions=json.dumps(get_transactions)
    )

    agentResponse = invoke_agent(agent_id, agent_alias_id, prompt)

        
    item = {
        "result_id": str(uuid.uuid4()),
        "user_id": agentResponse.get("user_id"),
        "value_of_transaction": agentResponse.get("value_of_transaction"),
        "location": agentResponse.get("location"),
        "confidence": agentResponse.get("confidence"),
        "is_fraud": agentResponse.get("is_fraud"),
        "reasoning": agentResponse.get("reasoning"),
    }

    store_item = fraud_results_table.put_item(Item=item)