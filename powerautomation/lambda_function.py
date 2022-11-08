import os
import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2_client = boto3.client('ec2')

def start_instance(instance_list):
    
    logger.info("Instance List:{0}".format(instance_list))
    start_instance_response = ec2_client.start_instances(
        InstanceIds=instance_list
    )
    return start_instance_response

def stop_instance(instance_list):
    
    logger.info("Instance List:{0}".format(instance_list))
    stop_instance_response = ec2_client.stop_instances(
        InstanceIds=instance_list
    )
    return stop_instance_response
    
def describe_instance_status(instance_list):
    
    
    describe_instance_status_response = ec2_client.describe_instance_status(
        InstanceIds=instance_list, IncludeAllInstances=True
    )
    return describe_instance_status_response

    
def lambda_handler(event, context):
    # TODO implement

    instance_mapping = json.loads(os.environ['INSTANCE_MAPPING'])
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    alarm_name = sns_message['AlarmName']
    logger.info("SNS Message:{0}".format(sns_message))
    logger.info("Alarm name:{0}".format(alarm_name))
    
    instance_list = instance_mapping[alarm_name]
    new_alarm_state = sns_message['NewStateValue']
    
    if new_alarm_state == "OK":
        
        describe_instance_status_response = describe_instance_status(instance_list)
    
        logger.info("describe_instance_status_response:{0}".format(describe_instance_status_response))
        
        instances_status = describe_instance_status_response['InstanceStatuses']
        
        modified_instance_list = []
        for instance in instances_status:
            if instance["InstanceState"]["Code"] == 80:
                modified_instance_list.append(instance['InstanceId'])
        
        if modified_instance_list:
            start_instance_response = start_instance(modified_instance_list)
            logger.info("start_instance_response:{0}".format(start_instance_response))
    
    elif new_alarm_state == "ALARM":
        
        describe_instance_status_response = describe_instance_status(instance_list)
        
        logger.info("describe_instance_status_response:{0}".format(describe_instance_status_response))
        
        instances_status = describe_instance_status_response['InstanceStatuses']
        
        modified_instance_list = []
        for instance in instances_status:
            if instance["InstanceState"]["Code"] == 16:
                modified_instance_list.append(instance['InstanceId'])

        if modified_instance_list:
            stop_instance_response = stop_instance(modified_instance_list)
            logger.info("stop_instance_response::{0}".format(stop_instance_response))
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
