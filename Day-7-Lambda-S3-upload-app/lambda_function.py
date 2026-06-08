import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Edwin! soure code hash checking (lambda_function.py file from S3')
    }