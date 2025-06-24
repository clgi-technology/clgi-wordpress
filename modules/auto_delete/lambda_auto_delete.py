import boto3
import datetime

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name='us-west-2')

    # Get all instances with 'AutoDelete' tag
    filters = [
        {
            'Name': 'tag:AutoDeleteAfter',
            'Values': ['true']
        }
    ]

    reservations = ec2.describe_instances(Filters=filters)['Reservations']
    now = datetime.datetime.utcnow()

    for reservation in reservations:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            launch_time = instance['LaunchTime'].replace(tzinfo=None)

            # If running > 24h, terminate
            if (now - launch_time).total_seconds() > 86400:
                print(f"Terminating instance {instance_id} - running > 24h")
                ec2.terminate_instances(InstanceIds=[instance_id])
            else:
                print(f"Instance {instance_id} is still within 24h window")
