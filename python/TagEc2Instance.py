import json
import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    print(event)

    user = event['detail']['userIdentity']['userName']
    instanceId = event['detail']['responseElements']['instancesSet']['items'][0]['instanceId']

    response = ec2.create_tags(
        Resources=[
            instanceId,
        ],
        Tags=[
            {
                'Key': 'Owner',
                'Value': user
            },
        ]
    )

    print('Tag InstanceId {} with owner {}'.format(instanceId, user))
    print(response)

    return