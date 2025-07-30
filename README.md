# AWS Media Streaming Terraform Module

A comprehensive, production-ready Terraform module for AWS media streaming infrastructure following entertainment industry standards. This module provides video processing, live streaming, and content delivery capabilities using AWS MediaConvert, MediaLive, MediaPackage, and CloudFront.

## 🎯 Features

### Video Processing
- **MediaConvert Integration**: Professional video transcoding with customizable job templates
- **Multi-format Output**: Support for HLS, DASH, MP4, and other formats
- **Adaptive Bitrate Streaming**: Multiple quality levels for optimal viewing experience
- **Automated Job Submission**: Optional Lambda-based automatic processing triggers
- **Cost Optimization**: Intelligent tiering and lifecycle policies

### Live Streaming
- **MediaLive Channels**: Professional-grade live video encoding
- **MediaPackage Distribution**: Reliable content packaging and origin services
- **Low Latency**: Optimized for real-time streaming applications
- **Redundancy**: Support for single and dual-pipeline configurations
- **DRM Support**: Optional content protection with SPEKE integration

### Content Delivery
- **CloudFront CDN**: Global content delivery with edge caching
- **Origin Access Control**: Secure S3 integration
- **Custom SSL**: Support for custom domains and certificates
- **Geo-restrictions**: Configurable geographic access controls
- **WAF Integration**: Optional web application firewall protection

### Security & Compliance
- **Encryption**: End-to-end encryption for storage and transit
- **IAM Best Practices**: Least-privilege access policies
- **VPC Integration**: Private network configurations
- **Audit Logging**: Comprehensive CloudWatch logging
- **Compliance**: SOC, PCI DSS, and HIPAA eligible services

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Video Input   │    │   Live Stream    │    │   S3 Storage    │
│   (S3 Upload)   │    │   (RTMP/RTP)     │    │   (Content)     │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          ▼                      ▼                       │
┌─────────────────┐    ┌──────────────────┐              │
│  MediaConvert   │    │   MediaLive      │              │
│  (Processing)   │    │   (Encoding)     │              │
└─────────┬───────┘    └─────────┬────────┘              │
          │                      │                       │
          ▼                      ▼                       │
┌─────────────────┐    ┌──────────────────┐              │
│  Processed S3   │    │  MediaPackage    │              │
│  (Output)       │    │  (Packaging)     │              │
└─────────┬───────┘    └─────────┬────────┘              │
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                                 ▼
                       ┌──────────────────┐
                       │   CloudFront     │
                       │   (CDN)          │
                       └─────────┬────────┘
                                 │
                                 ▼
                       ┌──────────────────┐
                       │   End Users      │
                       │   (Viewers)      │
                       └──────────────────┘
```

## 🚀 Quick Start

### Basic Usage

```hcl
module "media_streaming" {
  source = "./tfm-aws-mediastream"

  project_name = "my-streaming-platform"
  environment  = "prod"

  # Enable all features
  enable_video_processing = true
  enable_live_streaming   = true
  enable_content_delivery = true

  tags = {
    Project   = "MyStreamingApp"
    Owner     = "MediaTeam"
    ManagedBy = "Terraform"
  }
}
```

### Video Processing Only

```hcl
module "video_processing" {
  source = "./tfm-aws-mediastream"

  project_name = "video-processor"
  environment  = "prod"

  # Enable only video processing
  enable_video_processing = true
  enable_live_streaming   = false
  enable_content_delivery = true

  # Custom MediaConvert configuration
  mediaconvert_job_template_settings = {
    output_groups = [
      {
        name = "HLS_Adaptive"
        output_group_settings = {
          type = "HLS_GROUP_SETTINGS"
          hls_group_settings = {
            destination = "s3://my-bucket/hls/"
          }
        }
        outputs = [
          {
            name_modifier = "_1080p"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate = 8000000
                }
              }
              width  = 1920
              height = 1080
            }
          }
        ]
      }
    ]
  }
}
```

### Live Streaming Only

```hcl
module "live_streaming" {
  source = "./tfm-aws-mediastream"

  project_name = "live-broadcaster"
  environment  = "prod"

  # Enable only live streaming
  enable_video_processing = false
  enable_live_streaming   = true
  enable_content_delivery = true

  # Live streaming configuration
  medialive_input_type    = "RTMP_PUSH"
  medialive_channel_class = "STANDARD" # Dual pipeline
  
  # Low latency settings
  mediapackage_segment_duration = 2
  mediapackage_manifest_window  = 30
}
```

## 📋 Requirements

| Name | Version |
|------|--------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| random | ~> 3.1 |

## 🔧 Providers

| Name | Version |
|------|--------|
| aws | ~> 5.0 |
| random | ~> 3.1 |

## 📥 Inputs

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project, used for resource naming | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

### Feature Toggles

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_video_processing | Enable video processing with MediaConvert | `bool` | `true` | no |
| enable_live_streaming | Enable live streaming with MediaLive and MediaPackage | `bool` | `true` | no |
| enable_content_delivery | Enable content delivery with CloudFront | `bool` | `true` | no |

### S3 Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_versioning | Enable versioning for S3 buckets | `bool` | `true` | no |
| s3_encryption_algorithm | Server-side encryption algorithm for S3 buckets | `string` | `"AES256"` | no |
| kms_key_id | KMS key ID for S3 encryption (required if s3_encryption_algorithm is aws:kms) | `string` | `null` | no |

### CloudFront Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudfront_price_class | CloudFront distribution price class | `string` | `"PriceClass_100"` | no |
| cloudfront_viewer_protocol_policy | Protocol policy for viewers | `string` | `"redirect-to-https"` | no |
| cloudfront_certificate_arn | ARN of ACM certificate for custom domain | `string` | `null` | no |

### MediaConvert Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| mediaconvert_role_arn | IAM role ARN for MediaConvert service | `string` | `null` | no |
| mediaconvert_queue_priority | Priority for MediaConvert queue (-50 to 50) | `number` | `0` | no |
| mediaconvert_job_template_settings | MediaConvert job template settings | `object` | See variables.tf | no |

### MediaLive Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| medialive_input_type | Type of MediaLive input | `string` | `"RTMP_PUSH"` | no |
| medialive_channel_class | MediaLive channel class | `string` | `"SINGLE_PIPELINE"` | no |
| medialive_input_sources | List of input sources for MediaLive | `list(object)` | `[]` | no |

### MediaPackage Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| mediapackage_segment_duration | Duration of each segment in seconds | `number` | `6` | no |
| mediapackage_manifest_window | Time window for the live manifest in seconds | `number` | `60` | no |

## 📤 Outputs

### Content Delivery

| Name | Description |
|------|-------------|
| content_delivery_url | Primary URL for content delivery |
| live_streaming_playback_url | URL for live streaming playback |
| cloudfront_distribution_id | ID of the CloudFront distribution |
| cloudfront_distribution_domain_name | Domain name of the CloudFront distribution |

### S3 Storage

| Name | Description |
|------|-------------|
| source_content_bucket_id | ID of the source content S3 bucket |
| processed_content_bucket_id | ID of the processed content S3 bucket |
| live_content_bucket_id | ID of the live content S3 bucket |

### Video Processing

| Name | Description |
|------|-------------|
| video_processing_queue_arn | ARN of the MediaConvert queue |
| video_processing_job_template_arn | ARN of the MediaConvert job template |
| video_processing_role_arn | ARN of the MediaConvert service role |

### Live Streaming

| Name | Description |
|------|-------------|
| live_streaming_channel_arn | ARN of the MediaLive channel |
| live_streaming_channel_id | ID of the MediaLive channel |
| mediapackage_channel_id | ID of the MediaPackage channel |
| live_streaming_input_destinations | Destinations for the MediaLive input (sensitive) |

## 📁 Examples

The module includes several example configurations:

- **[basic-streaming](examples/basic-streaming/)**: Simple setup with all features enabled
- **[video-processing-only](examples/video-processing-only/)**: VOD processing with advanced encoding
- **[live-streaming-only](examples/live-streaming-only/)**: Live broadcasting with low latency
- **[complete](examples/complete/)**: Full-featured production setup with DRM and monitoring

## 🔒 Security Considerations

### Data Protection
- All S3 buckets use server-side encryption by default
- Public access is blocked on all storage buckets
- CloudFront uses HTTPS-only or redirect-to-HTTPS policies
- Optional KMS encryption for enhanced security

### Access Control
- IAM roles follow least-privilege principles
- Service-specific roles with minimal required permissions
- Origin Access Control (OAC) for secure S3-CloudFront integration
- Optional WAF integration for additional protection

### Network Security
- VPC integration available for private deployments
- Security groups with restrictive rules
- Optional DRM support for content protection
- Geo-restriction capabilities

## 💰 Cost Optimization

### Storage Optimization
- S3 Intelligent Tiering enabled by default
- Configurable lifecycle policies for automated archival
- Versioning can be disabled for cost savings

### Processing Optimization
- MediaConvert queue priority management
- Reserved capacity options for predictable workloads
- CloudFront caching strategies to reduce origin requests

### Monitoring
- CloudWatch metrics for cost tracking
- Estimated cost outputs for planning
- Resource tagging for cost allocation

## 📊 Monitoring and Logging

### CloudWatch Integration
- Comprehensive logging for all services
- Configurable log retention periods
- Custom metrics and alarms
- Cost and usage monitoring

### Observability
- Service-specific log groups
- Error tracking and alerting
- Performance metrics
- Usage analytics

## 🔄 CI/CD Integration

### Terraform Best Practices
- Remote state management with S3 backend
- State locking with DynamoDB
- Workspace separation for environments
- Automated validation and formatting

### Deployment Pipeline
```yaml
# Example GitHub Actions workflow
name: Deploy Media Streaming Infrastructure
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan
      - name: Terraform Apply
        run: terraform apply -auto-approve
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- 📧 Email: [support@example.com](mailto:support@example.com)
- 📖 Documentation: [Wiki](https://github.com/your-org/tfm-aws-mediastream/wiki)
- 🐛 Issues: [GitHub Issues](https://github.com/your-org/tfm-aws-mediastream/issues)

## 🙏 Acknowledgments

- AWS Media Services team for excellent documentation
- Terraform community for best practices
- Contributors and users of this module

---

**Built with ❤️ for the media streaming community**