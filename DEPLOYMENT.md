# Deployment Guide

This guide provides step-by-step instructions for deploying the AWS Media Streaming Terraform module.

## Prerequisites

### AWS Requirements
- AWS CLI configured with appropriate credentials
- AWS account with sufficient permissions for:
  - S3 (bucket creation and management)
  - CloudFront (distribution creation)
  - MediaConvert (queue and job template management)
  - MediaLive (channel and input management)
  - MediaPackage (channel and endpoint management)
  - IAM (role and policy management)
  - CloudWatch (log group management)

### Tools Required
- Terraform >= 1.0
- AWS CLI >= 2.0
- Git (for cloning the repository)

### Permissions
Ensure your AWS credentials have the following managed policies:
- `AmazonS3FullAccess`
- `CloudFrontFullAccess`
- `AWSElementalMediaConvertFullAccess`
- `AWSElementalMediaLiveFullAccess`
- `AWSElementalMediaPackageFullAccess`
- `IAMFullAccess`
- `CloudWatchLogsFullAccess`

## Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd tfm-aws-mediastream

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars`:

```hcl
# Required
project_name = "my-streaming-platform"
environment  = "prod"

# Optional - customize as needed
enable_video_processing = true
enable_live_streaming   = true
enable_content_delivery = true

# Add your specific configurations
tags = {
  Project = "MyStreamingApp"
  Owner   = "YourTeam"
}
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the infrastructure
terraform apply
```

## Deployment Scenarios

### Scenario 1: Video Processing Only

For VOD (Video on Demand) processing:

```hcl
# terraform.tfvars
project_name = "vod-processor"
environment  = "prod"

enable_video_processing = true
enable_live_streaming   = false
enable_content_delivery = true

# Enhanced video processing
mediaconvert_queue_priority = 10
```

### Scenario 2: Live Streaming Only

For live broadcasting:

```hcl
# terraform.tfvars
project_name = "live-broadcaster"
environment  = "prod"

enable_video_processing = false
enable_live_streaming   = true
enable_content_delivery = true

# Low latency configuration
medialive_channel_class = "STANDARD"
mediapackage_segment_duration = 2
```

### Scenario 3: Complete Platform

For full media streaming platform:

```hcl
# terraform.tfvars
project_name = "media-platform"
environment  = "prod"

enable_video_processing = true
enable_live_streaming   = true
enable_content_delivery = true

# Production settings
cloudfront_price_class = "PriceClass_All"
enable_drm = true
```

## Environment-Specific Deployments

### Development Environment

```bash
# Use workspace for environment separation
terraform workspace new dev
terraform workspace select dev

# Deploy with dev-specific variables
terraform apply -var="environment=dev" -var="cloudfront_price_class=PriceClass_100"
```

### Staging Environment

```bash
terraform workspace new staging
terraform workspace select staging

terraform apply -var="environment=staging"
```

### Production Environment

```bash
terraform workspace new prod
terraform workspace select prod

# Use production-grade configuration
terraform apply -var="environment=prod" -var="cloudfront_price_class=PriceClass_All"
```

## Remote State Configuration

For team collaboration, configure remote state:

### 1. Create S3 Backend

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "media-streaming/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
```

### 2. Initialize with Backend

```bash
terraform init -backend-config="bucket=your-terraform-state-bucket"
```

## Post-Deployment Configuration

### 1. Test Video Processing

Upload a test video to the source bucket:

```bash
aws s3 cp test-video.mp4 s3://$(terraform output -raw source_content_bucket_id)/input/
```

### 2. Configure Live Streaming

Get the RTMP endpoints:

```bash
# Get MediaLive input destinations (sensitive output)
terraform output live_streaming_input_destinations
```

### 3. Verify Content Delivery

Test the CloudFront distribution:

```bash
curl -I $(terraform output -raw content_delivery_url)
```

## Monitoring Setup

### 1. CloudWatch Dashboards

Create custom dashboards for monitoring:

```bash
# Example: Create MediaConvert dashboard
aws cloudwatch put-dashboard --dashboard-name "MediaConvert-$(terraform output -raw project_name)" --dashboard-body file://dashboards/mediaconvert.json
```

### 2. Alarms

Set up CloudWatch alarms:

```bash
# Example: MediaLive channel state alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "MediaLive-Channel-State" \
  --alarm-description "MediaLive channel not running" \
  --metric-name "ChannelState" \
  --namespace "AWS/MediaLive" \
  --statistic "Average" \
  --period 300 \
  --threshold 1 \
  --comparison-operator "LessThanThreshold"
```

## Troubleshooting

### Common Issues

#### 1. Permission Denied Errors

```bash
# Check IAM permissions
aws sts get-caller-identity
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query User.UserName --output text)
```

#### 2. Resource Limit Exceeded

```bash
# Check service quotas
aws service-quotas get-service-quota --service-code mediaconvert --quota-code L-34B43A08
```

#### 3. State Lock Issues

```bash
# Force unlock if needed (use with caution)
terraform force-unlock <lock-id>
```

### Debugging Commands

```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform apply

# Check AWS service status
aws mediaconvert describe-endpoints
aws medialive describe-channel --channel-id <channel-id>
```

## Cleanup

To destroy the infrastructure:

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy the infrastructure
terraform destroy
```

**Warning**: This will delete all resources including S3 buckets and their contents.

## Security Considerations

### 1. Credential Management

- Use IAM roles instead of access keys when possible
- Rotate credentials regularly
- Use AWS Secrets Manager for sensitive values

### 2. Network Security

- Consider VPC deployment for enhanced security
- Use security groups to restrict access
- Enable VPC Flow Logs for monitoring

### 3. Encryption

- Enable KMS encryption for enhanced security
- Use SSL/TLS for all data in transit
- Implement DRM for content protection

## Cost Optimization

### 1. Monitor Usage

```bash
# Check current costs
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-01-31 --granularity MONTHLY --metrics BlendedCost
```

### 2. Optimize Resources

- Use appropriate CloudFront price classes
- Implement S3 lifecycle policies
- Monitor and adjust MediaConvert queue priorities

### 3. Reserved Capacity

Consider reserved capacity for predictable workloads:
- MediaConvert reserved slots
- CloudFront reserved capacity
- S3 storage classes

## Support

For deployment issues:
1. Check the troubleshooting section
2. Review AWS service documentation
3. Open an issue in the repository
4. Contact AWS support for service-specific issues
