import json
import boto3
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

# Glue job client
glue_client = boto3.client('glue')

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
    name      = body.get("name")
    value     = body.get("value")
    location  = body.get("location")

    # Log the extracted parameters for debugging purposes
    logger.info(f"Extracted parameters: timestamp={timestamp}, name={name}, value={value}, location={location}")

    # Start the Glue job with the extracted parameters
    response = glue_client.start_job_run(
        jobName=os.getenv('GLUE_JOB_NAME'), 
        Arguments={
            '--timestamp': str(timestamp),
            '--name': str(name),
            '--value': str(value),
            '--location': str(location)
        }
    )

    logger.info(f"Glue job started successfully with JobRunId: {response['JobRunId']}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Glue job started successfully',
            'jobRunId': response['JobRunId']
        })
    }