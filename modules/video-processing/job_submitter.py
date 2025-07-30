import json
import boto3
import os
import urllib.parse
from datetime import datetime

def handler(event, context):
    """
    Lambda function to automatically submit MediaConvert jobs when files are uploaded to S3
    """
    
    # Initialize MediaConvert client
    mediaconvert = boto3.client('mediaconvert')
    
    # Get environment variables
    job_template_name = os.environ['JOB_TEMPLATE_NAME']
    queue_name = os.environ['QUEUE_NAME']
    role_arn = os.environ['ROLE_ARN']
    
    try:
        # Parse S3 event
        for record in event['Records']:
            # Get bucket and object key from the event
            bucket = record['s3']['bucket']['name']
            key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')
            
            # Create input file URI
            input_uri = f"s3://{bucket}/{key}"
            
            # Generate unique job name
            timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
            job_name = f"auto-job-{timestamp}-{key.split('/')[-1].split('.')[0]}"
            
            # Submit MediaConvert job
            response = mediaconvert.create_job(
                Role=role_arn,
                JobTemplate=job_template_name,
                Queue=queue_name,
                Settings={
                    'Inputs': [
                        {
                            'FileInput': input_uri,
                            'AudioSelectors': {},
                            'VideoSelector': {},
                            'TimecodeSource': 'ZEROBASED'
                        }
                    ]
                },
                UserMetadata={
                    'source_bucket': bucket,
                    'source_key': key,
                    'triggered_by': 'lambda_auto_submission'
                }
            )
            
            print(f"Successfully submitted job: {job_name}")
            print(f"Job ID: {response['Job']['Id']}")
            print(f"Input file: {input_uri}")
            
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'MediaConvert jobs submitted successfully',
                'jobs_submitted': len(event['Records'])
            })
        }
        
    except Exception as e:
        print(f"Error submitting MediaConvert job: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Failed to submit MediaConvert job'
            })
        }
