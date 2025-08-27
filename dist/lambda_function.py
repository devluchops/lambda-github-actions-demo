import json

def lambda_handler(event, context):
    """
    AWS Lambda function that returns a hello world message.
    """
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'Hello World from AWS Lambda!',
            'event': event,
            'function_name': context.function_name if context else 'local',
            'request_id': context.aws_request_id if context else 'local'
        })
    }