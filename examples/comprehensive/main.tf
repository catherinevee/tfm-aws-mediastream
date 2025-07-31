# ==============================================================================
# COMPREHENSIVE MEDIA STREAMING EXAMPLE - MAXIMUM CUSTOMIZABILITY DEMONSTRATION
# ==============================================================================
# This example demonstrates the extensive customization capabilities of the
# enhanced Media Streaming module, showcasing all available parameters and
# production-ready configurations for entertainment industry standards

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources for networking
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

# KMS key for encryption
resource "aws_kms_key" "media_encryption" {
  description             = "KMS key for media streaming encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow MediaConvert Service"
        Effect = "Allow"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-media-encryption"
    Environment = var.environment
    Purpose     = "Media content encryption"
  }
}

resource "aws_kms_alias" "media_encryption" {
  name          = "alias/${var.project_name}-media-encryption"
  target_key_id = aws_kms_key.media_encryption.key_id
}

# Get current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Comprehensive Media Streaming module with maximum customization
module "media_streaming_comprehensive" {
  source = "../../"

  # ==============================================================================
  # CORE PROJECT CONFIGURATION
  # ==============================================================================
  project_name = var.project_name
  environment  = var.environment
  
  # Comprehensive tagging strategy for enterprise governance
  tags = {
    Project             = var.project_name
    Environment         = var.environment
    Application         = "media-streaming"
    BusinessUnit        = var.business_unit
    CostCenter          = var.cost_center
    Owner               = var.owner
    ManagedBy           = "Terraform"
    Module              = "tfm-aws-mediastream-comprehensive"
    SecurityReview      = "approved"
    DataRetention       = var.data_retention_policy
    MonitoringEnabled   = "true"
    BackupRequired      = "true"
    ComplianceRequired  = var.compliance_framework != "none" ? "true" : "false"
  }
  
  # Enhanced metadata for governance and compliance
  cost_center           = var.cost_center
  owner                = var.owner
  compliance_framework = var.compliance_framework
  data_classification  = var.data_classification
  backup_required      = var.backup_required

  # ==============================================================================
  # FEATURE TOGGLES - MODULAR ARCHITECTURE
  # ==============================================================================
  enable_video_processing = var.enable_video_processing
  enable_live_streaming   = var.enable_live_streaming
  enable_content_delivery = var.enable_content_delivery

  # ==============================================================================
  # NETWORKING CONFIGURATION - VPC AND SECURITY
  # ==============================================================================
  vpc_id             = data.aws_vpc.main.id
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = var.custom_security_group_ids
  
  # MediaLive input security configuration
  medialive_input_security_enabled   = var.medialive_input_security_enabled
  medialive_input_whitelist_cidrs     = var.medialive_input_whitelist_cidrs

  # ==============================================================================
  # S3 STORAGE CONFIGURATION - ADVANCED STORAGE MANAGEMENT
  # ==============================================================================
  # Versioning for content protection and rollback capability
  enable_versioning = var.enable_versioning
  
  # Encryption configuration - KMS for enhanced security
  s3_encryption_algorithm = "aws:kms"
  kms_key_id             = aws_kms_key.media_encryption.arn
  
  # Advanced lifecycle management for cost optimization
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
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = var.content_retention_days
      }
      noncurrent_version_transitions = [
        {
          days          = 7
          storage_class = "STANDARD_IA"
        },
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = 90
      }
    },
    {
      id     = "processed-content-lifecycle"
      status = "Enabled"
      transitions = [
        {
          days          = 7
          storage_class = "STANDARD_IA"
        },
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = var.processed_content_retention_days
      }
    }
  ]

  # ==============================================================================
  # CLOUDFRONT CDN CONFIGURATION - GLOBAL CONTENT DELIVERY
  # ==============================================================================
  # Performance and cost optimization
  cloudfront_price_class = var.cloudfront_price_class
  
  # HTTP methods configuration for different content types
  cloudfront_allowed_methods = var.cloudfront_allowed_methods
  cloudfront_cached_methods  = var.cloudfront_cached_methods
  
  # Security and protocol configuration
  cloudfront_viewer_protocol_policy     = "redirect-to-https"
  cloudfront_minimum_protocol_version   = "TLSv1.2_2021"
  cloudfront_ssl_support_method        = "sni-only"
  
  # Custom SSL certificate for branded domains
  cloudfront_acm_certificate_arn = var.cloudfront_acm_certificate_arn
  cloudfront_aliases             = var.cloudfront_aliases
  
  # Advanced caching configuration
  cloudfront_default_ttl = var.cloudfront_default_ttl
  cloudfront_max_ttl     = var.cloudfront_max_ttl
  cloudfront_min_ttl     = var.cloudfront_min_ttl
  
  # Geographic restrictions for content licensing
  cloudfront_geo_restriction_type      = var.cloudfront_geo_restriction_type
  cloudfront_geo_restriction_locations = var.cloudfront_geo_restriction_locations
  
  # Web Application Firewall integration
  cloudfront_web_acl_id = var.cloudfront_web_acl_id
  
  # Custom error pages for better user experience
  cloudfront_custom_error_responses = var.cloudfront_custom_error_responses
  
  # Origin configuration for advanced scenarios
  cloudfront_origin_access_control_enabled = true
  cloudfront_compress                      = true

  # ==============================================================================
  # VIDEO PROCESSING CONFIGURATION - MEDIACONVERT ADVANCED SETTINGS
  # ==============================================================================
  # MediaConvert queue configuration
  mediaconvert_queue_name        = "${var.project_name}-video-processing"
  mediaconvert_queue_description = "High-priority queue for ${var.project_name} video processing"
  mediaconvert_queue_priority    = var.mediaconvert_queue_priority
  mediaconvert_queue_pricing_plan = var.mediaconvert_queue_pricing_plan
  
  # Advanced video encoding profiles for different use cases
  video_descriptions = [
    {
      name        = "4K-UHD"
      width       = 3840
      height      = 2160
      bitrate     = 15000000
      max_bitrate = 20000000
      codec       = "H_264"
      profile     = "HIGH"
      level       = "5.1"
      rate_control_mode = "QVBR"
      qvbr_quality_level = 8
    },
    {
      name        = "1080p-High"
      width       = 1920
      height      = 1080
      bitrate     = 8000000
      max_bitrate = 10000000
      codec       = "H_264"
      profile     = "HIGH"
      level       = "4.0"
      rate_control_mode = "QVBR"
      qvbr_quality_level = 7
    },
    {
      name        = "1080p-Standard"
      width       = 1920
      height      = 1080
      bitrate     = 5000000
      max_bitrate = 6000000
      codec       = "H_264"
      profile     = "MAIN"
      level       = "4.0"
      rate_control_mode = "VBR"
    },
    {
      name        = "720p-High"
      width       = 1280
      height      = 720
      bitrate     = 3500000
      max_bitrate = 4000000
      codec       = "H_264"
      profile     = "MAIN"
      level       = "3.1"
      rate_control_mode = "VBR"
    },
    {
      name        = "720p-Standard"
      width       = 1280
      height      = 720
      bitrate     = 2500000
      max_bitrate = 3000000
      codec       = "H_264"
      profile     = "MAIN"
      level       = "3.1"
      rate_control_mode = "CBR"
    },
    {
      name        = "480p-Mobile"
      width       = 854
      height      = 480
      bitrate     = 1200000
      max_bitrate = 1500000
      codec       = "H_264"
      profile     = "BASELINE"
      level       = "3.0"
      rate_control_mode = "CBR"
    }
  ]
  
  # Professional audio encoding configurations
  audio_descriptions = [
    {
      name         = "stereo-high"
      bitrate      = 256000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_2_0"
      codec        = "AAC"
      profile      = "LC"
    },
    {
      name         = "stereo-standard"
      bitrate      = 128000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_2_0"
      codec        = "AAC"
      profile      = "LC"
    },
    {
      name         = "surround-5.1"
      bitrate      = 384000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_5_1"
      codec        = "AAC"
      profile      = "LC"
    }
  ]

  # ==============================================================================
  # LIVE STREAMING CONFIGURATION - MEDIALIVE AND MEDIAPACKAGE
  # ==============================================================================
  # MediaLive channel configuration
  medialive_channel_class = var.medialive_channel_class
  medialive_input_type    = var.medialive_input_type
  
  # Advanced video encoding for live streaming
  medialive_video_descriptions = [
    {
      name        = "1080p60"
      width       = 1920
      height      = 1080
      bitrate     = 6000000
      max_bitrate = 8000000
      framerate   = 60
      codec       = "H264"
      profile     = "HIGH"
      level       = "4.2"
      rate_control_mode = "QVBR"
      qvbr_quality_level = 7
    },
    {
      name        = "720p60"
      width       = 1280
      height      = 720
      bitrate     = 4000000
      max_bitrate = 5000000
      framerate   = 60
      codec       = "H264"
      profile     = "HIGH"
      level       = "3.2"
      rate_control_mode = "QVBR"
      qvbr_quality_level = 7
    },
    {
      name        = "480p30"
      width       = 854
      height      = 480
      bitrate     = 1500000
      max_bitrate = 2000000
      framerate   = 30
      codec       = "H264"
      profile     = "MAIN"
      level       = "3.1"
      rate_control_mode = "CBR"
    }
  ]
  
  # Professional audio for live streaming
  medialive_audio_descriptions = [
    {
      name         = "live-audio-primary"
      bitrate      = 128000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_2_0"
    },
    {
      name         = "live-audio-backup"
      bitrate      = 96000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_2_0"
    }
  ]
  
  # MediaPackage configuration for multi-format delivery
  enable_hls  = var.enable_hls
  enable_dash = var.enable_dash
  enable_mss  = var.enable_mss
  
  # Advanced packaging settings
  mediapackage_segment_duration = var.mediapackage_segment_duration
  mediapackage_playlist_window  = var.mediapackage_playlist_window
  
  # DRM protection for premium content
  enable_drm           = var.enable_drm
  drm_system_ids       = var.drm_system_ids
  drm_key_provider_url = var.drm_key_provider_url
  drm_key_rotation_seconds = var.drm_key_rotation_seconds

  # ==============================================================================
  # MONITORING AND LOGGING CONFIGURATION
  # ==============================================================================
  enable_cloudwatch_logs = var.enable_cloudwatch_logs
  log_retention_days     = var.log_retention_days
  
  # Custom CloudWatch metrics and alarms
  enable_custom_metrics = var.enable_custom_metrics
  
  # SNS topic for alerts and notifications
  sns_topic_arn = var.sns_topic_arn

  # ==============================================================================
  # COST OPTIMIZATION CONFIGURATION
  # ==============================================================================
  # Reserved capacity for predictable workloads
  mediaconvert_reserved_queue_slots = var.mediaconvert_reserved_queue_slots
  
  # Spot pricing for non-critical processing
  enable_spot_pricing = var.enable_spot_pricing
  
  # Automated scaling based on queue depth
  enable_auto_scaling = var.enable_auto_scaling
  
  # Content delivery optimization
  cloudfront_compress = true
  
  # S3 intelligent tiering for automatic cost optimization
  enable_intelligent_tiering = var.enable_intelligent_tiering
}
