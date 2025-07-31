# Comprehensive Media Streaming Example

This example demonstrates the **maximum customizability** of the enhanced AWS Media Streaming Terraform module, showcasing all available parameters and production-ready configurations suitable for enterprise media streaming platforms.

## 🎯 Overview

This comprehensive example creates a full-featured media streaming infrastructure with:

- **Video Processing**: Advanced MediaConvert configurations with multiple encoding profiles
- **Live Streaming**: MediaLive and MediaPackage with professional broadcast settings
- **Content Delivery**: Global CloudFront CDN with security and performance optimization
- **Storage Management**: S3 with intelligent tiering and lifecycle policies
- **Security**: End-to-end encryption, DRM protection, and compliance frameworks
- **Monitoring**: CloudWatch integration with custom metrics and alerting
- **Cost Optimization**: Multiple strategies for reducing operational costs

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Live Input    │───▶│   MediaLive      │───▶│  MediaPackage   │
│  (RTMP/RTP)     │    │   (Encoding)     │    │  (Packaging)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
┌─────────────────┐    ┌──────────────────┐             │
│  Source Content │───▶│  MediaConvert    │             │
│     (S3)        │    │  (Processing)    │             │
└─────────────────┘    └──────────────────┘             │
                                │                       │
                                ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Processed       │◀───│  CloudFront CDN  │◀───│  Live Streams   │
│ Content (S3)    │    │  (Global Edge)   │    │  (HLS/DASH)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   End Users     │
                       │  (Global)       │
                       └─────────────────┘
```

## 🚀 Features Demonstrated

### Core Infrastructure
- ✅ **Multi-format Support**: HLS, DASH, and MSS streaming protocols
- ✅ **Adaptive Bitrate**: Multiple resolution and bitrate profiles
- ✅ **Global CDN**: CloudFront with edge locations worldwide
- ✅ **Auto-scaling**: Dynamic resource scaling based on demand

### Security & Compliance
- ✅ **End-to-end Encryption**: KMS encryption for all storage and transit
- ✅ **DRM Protection**: SPEKE integration for premium content
- ✅ **Network Isolation**: VPC with private subnets
- ✅ **Compliance Frameworks**: SOC2, PCI-DSS, HIPAA support
- ✅ **Access Controls**: IAM roles with least privilege principles

### Monitoring & Operations
- ✅ **CloudWatch Integration**: Comprehensive logging and metrics
- ✅ **Custom Dashboards**: Operational visibility and alerting
- ✅ **Cost Tracking**: Detailed cost allocation and optimization
- ✅ **Performance Monitoring**: Real-time streaming quality metrics

### Cost Optimization
- ✅ **S3 Lifecycle Policies**: Automated storage class transitions
- ✅ **Intelligent Tiering**: AI-driven storage optimization
- ✅ **Reserved Capacity**: Predictable workload cost reduction
- ✅ **Spot Pricing**: Non-critical workload cost savings

## 📋 Prerequisites

### AWS Account Setup
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- VPC with private subnets (or use default VPC)
- ACM certificate for custom domains (optional)

### Required Permissions
The deploying user/role needs permissions for:
- S3 (buckets, objects, lifecycle)
- CloudFront (distributions, origins)
- MediaConvert (queues, jobs, presets)
- MediaLive (channels, inputs, security groups)
- MediaPackage (channels, endpoints)
- KMS (keys, aliases, policies)
- IAM (roles, policies)
- CloudWatch (logs, metrics, alarms)

## 🛠️ Deployment Guide

### Step 1: Clone and Navigate
```bash
git clone <repository-url>
cd tfm-aws-mediastream/examples/comprehensive
```

### Step 2: Configure Variables
Create a `terraform.tfvars` file:

```hcl
# Basic Configuration
project_name = "my-media-platform"
environment  = "prod"
aws_region   = "us-east-1"

# Networking (optional - uses default VPC if not specified)
vpc_name = "my-vpc"

# Features to Enable
enable_video_processing = true
enable_live_streaming   = true
enable_content_delivery = true

# Security Configuration
compliance_framework = "SOC2"
data_classification  = "confidential"
enable_drm          = true

# Custom Domain (optional)
cloudfront_aliases = ["streaming.example.com"]
cloudfront_acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# Cost Optimization
mediaconvert_queue_pricing_plan = "RESERVED"
mediaconvert_reserved_queue_slots = 5
enable_intelligent_tiering = true

# Monitoring
enable_cloudwatch_logs = true
enable_custom_metrics  = true
sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:media-alerts"
```

### Step 3: Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### Step 4: Verify Deployment
```bash
# Check outputs
terraform output

# Verify resources in AWS Console
terraform output operational_urls
```

## 📊 Configuration Examples

### Video Processing Profiles
The example includes professional encoding profiles:

```hcl
video_descriptions = [
  {
    name        = "4K-UHD"
    width       = 3840
    height      = 2160
    bitrate     = 15000000
    codec       = "H_264"
    profile     = "HIGH"
  },
  {
    name        = "1080p-High"
    width       = 1920
    height      = 1080
    bitrate     = 8000000
    codec       = "H_264"
    profile     = "HIGH"
  }
  # ... additional profiles
]
```

### Live Streaming Configuration
Professional broadcast settings:

```hcl
medialive_video_descriptions = [
  {
    name        = "1080p60"
    width       = 1920
    height      = 1080
    bitrate     = 6000000
    framerate   = 60
    codec       = "H264"
    profile     = "HIGH"
  }
  # ... additional configurations
]
```

### Storage Lifecycle Management
Automated cost optimization:

```hcl
lifecycle_rules = [
  {
    id     = "source-content-lifecycle"
    status = "Enabled"
    transitions = [
      {
        days          = 30
        storage_class = "STANDARD_IA"
      },
      {
        days          = 90
        storage_class = "GLACIER"
      }
    ]
  }
]
```

## 🔧 Customization Options

### Encoding Profiles
Modify `video_descriptions` and `audio_descriptions` to match your content requirements:
- Resolution and bitrate combinations
- Codec settings (H.264, H.265, AV1)
- Rate control modes (CBR, VBR, QVBR)
- Audio formats and bitrates

### CDN Configuration
Customize CloudFront settings:
- Geographic restrictions
- Custom SSL certificates
- Cache behaviors and TTL settings
- Web Application Firewall rules

### Security Settings
Configure security features:
- DRM system integration
- Input security whitelisting
- Encryption key rotation
- Compliance framework alignment

### Cost Optimization
Adjust cost optimization features:
- Storage lifecycle policies
- Reserved capacity allocation
- Spot pricing for batch jobs
- CDN price class selection

## 📈 Monitoring and Alerting

### CloudWatch Metrics
The deployment creates custom metrics for:
- Video processing job success/failure rates
- Live stream health and quality metrics
- CDN performance and error rates
- Storage utilization and costs

### Recommended Alarms
Set up CloudWatch alarms for:
- MediaConvert job failures
- MediaLive channel errors
- High CDN error rates
- Unusual storage costs

### Dashboard Creation
Create CloudWatch dashboards to monitor:
- Real-time streaming metrics
- Processing queue depths
- Global CDN performance
- Cost trends and optimization opportunities

## 💰 Cost Optimization Strategies

### Storage Optimization
- **Intelligent Tiering**: Automatically moves objects between storage classes
- **Lifecycle Policies**: Transitions to cheaper storage classes over time
- **Versioning Management**: Automatic cleanup of old versions

### Processing Optimization
- **Reserved Capacity**: Predictable workloads benefit from reserved pricing
- **Spot Pricing**: Use for non-critical batch processing
- **Queue Prioritization**: Optimize resource allocation

### CDN Optimization
- **Price Class Selection**: Choose appropriate geographic coverage
- **Compression**: Enable automatic compression for text content
- **Cache Optimization**: Configure appropriate TTL values

## 🔍 Troubleshooting

### Common Issues

#### MediaLive Channel Won't Start
- Check input security group rules
- Verify subnet configuration in multiple AZs
- Ensure proper IAM permissions

#### MediaConvert Jobs Failing
- Verify S3 bucket permissions
- Check input file formats and codecs
- Review job template configurations

#### CloudFront Distribution Issues
- Verify origin access control settings
- Check SSL certificate configuration
- Review geographic restrictions

### Debugging Commands
```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# View detailed logs
terraform apply -auto-approve -var-file=terraform.tfvars

# Destroy resources (be careful!)
terraform destroy
```

## 🔒 Security Best Practices

### Encryption
- All S3 buckets use KMS encryption
- CloudFront enforces HTTPS
- MediaLive uses encrypted inputs
- DRM protection for premium content

### Access Control
- IAM roles follow least privilege principle
- VPC isolation for network security
- Input security groups for MediaLive
- Origin access control for CloudFront

### Compliance
- Configurable compliance frameworks
- Audit logging enabled
- Data classification tagging
- Retention policy enforcement

## 📚 Additional Resources

### AWS Documentation
- [AWS Media Services](https://docs.aws.amazon.com/media-services/)
- [MediaConvert User Guide](https://docs.aws.amazon.com/mediaconvert/)
- [MediaLive User Guide](https://docs.aws.amazon.com/medialive/)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/)

### Terraform Resources
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

### Industry Standards
- [HLS Specification](https://tools.ietf.org/html/rfc8216)
- [DASH Standard](https://dashif.org/)
- [SPEKE Specification](https://docs.aws.amazon.com/speke/latest/documentation/)

## 🤝 Support and Contributing

### Getting Help
- Review the troubleshooting section above
- Check AWS service health dashboards
- Contact AWS support for service-specific issues

### Contributing
- Submit issues for bugs or feature requests
- Contribute improvements via pull requests
- Share your configuration examples

## 📄 License

This example is provided under the same license as the main module. See the LICENSE file for details.

---

**Note**: This comprehensive example demonstrates advanced features and configurations. For simpler use cases, consider the basic examples in the parent directory. Always review and test configurations in a development environment before deploying to production.
