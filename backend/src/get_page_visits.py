import json
import boto3

# Instantiate dynamodb object outside the handler
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('pageVisits')

# Currently it does not count unique page-visits
def lambda_handler(event, context):
    response = table.update_item(
        Key={
            'page_counter': 'page_counter_id'
        },
        UpdateExpression='SET visitors = visitors + :val',
        ExpressionAttributeValues={
            ':val': 1
        },
        ReturnValues='UPDATED_NEW'
    )

    visitors_count = response['Attributes']['visitors']

    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "*", 
            "Access-Control-Allow-Methods": "GET" 
        },
        'body': json.dumps(f'visitors: {visitors_count}')
    }