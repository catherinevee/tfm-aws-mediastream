# Complete Production Media Streaming Example

This example demonstrates a full-featured, production-ready media streaming infrastructure with all advanced features enabled.

## Features Included

- **Video Processing**: Advanced MediaConvert configuration with multiple output formats (HLS, DASH)
- **Live Streaming**: Professional-grade live streaming with dual pipeline redundancy
- **Content Delivery**: Global CloudFront distribution with custom domain support
- **Security**: KMS encryption, DRM protection, and geo-restrictions
- **Monitoring**: Enhanced CloudWatch logging and metrics
- **Cost Optimization**: Intelligent tiering and lifecycle policies

## Architecture

This example creates:

- MediaConvert queue and job templates for 4K, 1080p, 720p, and 480p outputs
- MediaLive channel with STANDARD class (dual pipeline)
- MediaPackage with both HLS and DASH endpoints
- CloudFront distribution with global edge locations
- S3 buckets with intelligent tiering and lifecycle policies
- IAM roles with least-privilege permissions
- CloudWatch log groups for monitoring

## Prerequisites

1. **AWS Account**: With appropriate permissions for media services
2. **KMS Key**: For enhanced S3 encryption (optional)
3. **ACM Certificate**: For custom domain (optional)
4. **DRM Provider**: SPEKE-compliant key provider for DRM (optional)

## Usage

1. **Copy the example**:
   ```bash
   cp -r examples/complete my-streaming-platform
   cd my-streaming-platform
   ```

2. **Configure variables**:
   ```bash
   cp variables.tf terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

```hcl
project_name = "production-media-streaming"
environment  = "prod"
aws_region   = "us-east-1"
```

### Optional Variables

```hcl
# KMS encryption
kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Custom domain
cloudfront_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# DRM protection
enable_drm = true
drm_key_provider_url = "https://your-drm-provider.com/speke"
```

## Video Profiles

This example creates multiple video profiles optimized for different use cases:

### VOD Processing
- **4K HEVC**: 20 Mbps, 60fps for premium content
- **1080p60**: 10 Mbps, 60fps for high-quality streaming
- **720p30**: 5 Mbps, 30fps for standard quality
- **480p30**: 2 Mbps, 30fps for mobile/low bandwidth

### Live Streaming
- **1080p60 Premium**: 8 Mbps CBR for professional broadcasts
- **720p60 Standard**: 5 Mbps CBR for standard live streams
- **480p30 Mobile**: 1.5 Mbps CBR for mobile viewers

## Cost Considerations

This is a production-grade configuration that includes:

- **MediaConvert**: ~$0.0075-0.024 per minute (varies by output)
- **MediaLive**: ~$3.00/hour for STANDARD channel class
- **MediaPackage**: ~$0.07 per GB delivered
- **CloudFront**: ~$0.085-0.25 per GB (varies by region)
- **S3**: ~$0.023 per GB stored (with intelligent tiering)

**Estimated monthly cost for moderate usage**: $500-2000+ depending on content volume and viewership.

## Security Features

- **Encryption**: All data encrypted at rest and in transit
- **Access Control**: IAM roles with minimal required permissions
- **Network Security**: Origin Access Control for S3-CloudFront integration
- **Content Protection**: Optional DRM with multi-DRM support
- **Geo-restrictions**: Configurable geographic access controls

## Monitoring

The example includes comprehensive monitoring:

- **CloudWatch Logs**: Service-specific log groups with 90-day retention
- **Metrics**: Built-in CloudWatch metrics for all services
- **Alarms**: Can be configured for operational monitoring
- **Cost Tracking**: Resource tagging for cost allocation

## Scaling Considerations

This configuration supports:

- **Concurrent Viewers**: 10,000+ with CloudFront caching
- **Live Streams**: Multiple simultaneous channels
- **VOD Processing**: Parallel job processing with queue priority
- **Global Delivery**: Edge locations worldwide

## Troubleshooting

### Common Issues

1. **MediaLive Channel Creation Fails**
   - Verify IAM permissions for MediaLive service
   - Check input security group configuration

2. **MediaConvert Jobs Fail**
   - Verify S3 bucket permissions
   - Check job template configuration

3. **CloudFront Access Denied**
   - Verify Origin Access Control configuration
   - Check S3 bucket policy

### Useful Commands

```bash
# Check MediaLive channel status
aws medialive describe-channel --channel-id <channel-id>

# List MediaConvert jobs
aws mediaconvert list-jobs --queue <queue-arn>

# Check CloudFront distribution status
aws cloudfront get-distribution --id <distribution-id>
```

## Next Steps

After deployment:

1. **Test Video Upload**: Upload a test video to the source S3 bucket
2. **Configure Live Stream**: Set up your encoder to push to MediaLive
3. **Test Playback**: Verify content plays through CloudFront URLs
4. **Set Up Monitoring**: Configure CloudWatch alarms and notifications
5. **Optimize Costs**: Review usage patterns and adjust configurations

## Support

For issues specific to this example:
- Check the main module documentation
- Review AWS service documentation
- Open an issue in the repository
