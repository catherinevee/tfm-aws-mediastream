# ==============================================================================
# AWS MEDIA STREAMING TERRAFORM MODULE - ENHANCED FOR MAXIMUM CUSTOMIZABILITY
# ==============================================================================
# This module provides comprehensive media streaming capabilities including:
# - Video processing with AWS MediaConvert and advanced encoding profiles
# - Live streaming with AWS MediaLive, MediaPackage, and low-latency options
# - Content delivery with CloudFront CDN and global edge optimization
# - S3 storage with lifecycle management and cost optimization
# - DRM protection with SPEKE integration for content security
# - Monitoring and analytics with CloudWatch and custom metrics
# Default values are optimized for production use and entertainment industry standards

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# ==============================================================================
# DATA SOURCES - DYNAMIC RESOURCE DISCOVERY
# ==============================================================================

# Current AWS account information for resource naming and policies
data "aws_caller_identity" "current" {}

# Current AWS region for regional resource configuration
data "aws_region" "current" {}

# Availability zones for multi-AZ deployments
data "aws_availability_zones" "available" {
  state = "available"
}

# Default VPC for network configuration (if not specified)
data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

# Subnets for MediaLive and other network resources
data "aws_subnets" "default" {
  count = var.vpc_id == null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

# ==============================================================================
# RANDOM RESOURCES - UNIQUE NAMING
# ==============================================================================

# Random suffix for globally unique S3 bucket names
# Ensures bucket names don't conflict across AWS accounts
random_id "bucket_suffix" {
  byte_length = 4
}

# Random password for MediaLive input security (if needed)
random_password "medialive_input_key" {
  count   = var.enable_live_streaming && var.medialive_input_security_enabled ? 1 : 0
  length  = 32
  special = false
}

# ==============================================================================
# LOCAL VALUES - COMPUTED CONFIGURATIONS
# ==============================================================================

locals {
  # Comprehensive tagging strategy
  # Combines user tags with automatic module tags for complete resource tracking
  common_tags = merge(
    var.tags,                                    # User-provided tags
    {
      Module         = "tfm-aws-mediastream"     # Module identifier
      Environment    = var.environment           # Environment classification
      ManagedBy      = "Terraform"              # Management tool
      CreatedBy      = data.aws_caller_identity.current.user_id
      Region         = data.aws_region.current.name
      Project        = var.project_name          # Project association
      CostCenter     = var.cost_center           # Billing allocation
      Owner          = var.owner                 # Resource ownership
      Compliance     = var.compliance_framework  # Regulatory compliance
      DataClass      = var.data_classification   # Data sensitivity
      BackupRequired = var.backup_required       # Backup policy
      CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
    }
  )
  
  # VPC configuration - uses provided VPC or default VPC
  vpc_id = var.vpc_id != null ? var.vpc_id : (
    length(data.aws_vpc.default) > 0 ? data.aws_vpc.default[0].id : null
  )
  
  # Subnet configuration for multi-AZ deployments
  subnet_ids = var.subnet_ids != null && length(var.subnet_ids) > 0 ? var.subnet_ids : (
    length(data.aws_subnets.default) > 0 ? data.aws_subnets.default[0].ids : []
  )
  
  # S3 bucket names with unique suffixes
  source_bucket_name = "${var.project_name}-source-content-${random_id.bucket_suffix.hex}"
  processed_bucket_name = "${var.project_name}-processed-content-${random_id.bucket_suffix.hex}"
  
  # CloudFront origin domain names
  source_origin_domain = var.enable_video_processing || var.enable_content_delivery ? aws_s3_bucket.source_content[0].bucket_regional_domain_name : null
  processed_origin_domain = var.enable_video_processing ? aws_s3_bucket.processed_content[0].bucket_regional_domain_name : null
  
  # MediaPackage endpoint URLs for live streaming
  mediapackage_endpoints = var.enable_live_streaming ? {
    hls  = module.live_streaming[0].mediapackage_hls_endpoint
    dash = module.live_streaming[0].mediapackage_dash_endpoint
    mss  = module.live_streaming[0].mediapackage_mss_endpoint
  } : {}
}

# S3 Buckets for media storage
resource "aws_s3_bucket" "source_content" {
  count  = var.enable_video_processing || var.enable_content_delivery ? 1 : 0
  bucket = "${var.project_name}-source-content-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-source-content"
    Purpose     = "Source media content storage"
    ContentType = "Raw media files"
  })
}

resource "aws_s3_bucket" "processed_content" {
  count  = var.enable_video_processing ? 1 : 0
  bucket = "${var.project_name}-processed-content-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-processed-content"
    Purpose     = "Processed media content storage"
    ContentType = "Transcoded media files"
  })
}

resource "aws_s3_bucket" "live_content" {
  count  = var.enable_live_streaming ? 1 : 0
  bucket = "${var.project_name}-live-content-${random_id.bucket_suffix.hex}"

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-live-content"
    Purpose     = "Live streaming content storage"
    ContentType = "Live stream segments"
  })
}

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket configurations
resource "aws_s3_bucket_versioning" "source_content" {
  count  = var.enable_video_processing || var.enable_content_delivery ? 1 : 0
  bucket = aws_s3_bucket.source_content[0].id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "processed_content" {
  count  = var.enable_video_processing ? 1 : 0
  bucket = aws_s3_bucket.processed_content[0].id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_content" {
  count  = var.enable_video_processing || var.enable_content_delivery ? 1 : 0
  bucket = aws_s3_bucket.source_content[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_encryption_algorithm
      kms_master_key_id = var.s3_encryption_algorithm == "aws:kms" ? var.kms_key_id : null
    }
    bucket_key_enabled = var.s3_encryption_algorithm == "aws:kms" ? true : null
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_content" {
  count  = var.enable_video_processing ? 1 : 0
  bucket = aws_s3_bucket.processed_content[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_encryption_algorithm
      kms_master_key_id = var.s3_encryption_algorithm == "aws:kms" ? var.kms_key_id : null
    }
    bucket_key_enabled = var.s3_encryption_algorithm == "aws:kms" ? true : null
  }
}

resource "aws_s3_bucket_public_access_block" "source_content" {
  count  = var.enable_video_processing || var.enable_content_delivery ? 1 : 0
  bucket = aws_s3_bucket.source_content[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "processed_content" {
  count  = var.enable_video_processing ? 1 : 0
  bucket = aws_s3_bucket.processed_content[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "main" {
  count                             = var.enable_content_delivery ? 1 : 0
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} media streaming"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution for Content Delivery
resource "aws_cloudfront_distribution" "main" {
  count   = var.enable_content_delivery ? 1 : 0
  comment = "${var.project_name} Media Streaming Distribution"
  enabled = true

  # Origin for processed content
  dynamic "origin" {
    for_each = var.enable_video_processing ? [1] : []
    content {
      domain_name              = aws_s3_bucket.processed_content[0].bucket_regional_domain_name
      origin_id                = "S3-${aws_s3_bucket.processed_content[0].id}"
      origin_access_control_id = aws_cloudfront_origin_access_control.main[0].id
    }
  }

  # Origin for source content (if no video processing)
  dynamic "origin" {
    for_each = !var.enable_video_processing && (var.enable_content_delivery) ? [1] : []
    content {
      domain_name              = aws_s3_bucket.source_content[0].bucket_regional_domain_name
      origin_id                = "S3-${aws_s3_bucket.source_content[0].id}"
      origin_access_control_id = aws_cloudfront_origin_access_control.main[0].id
    }
  }

  # Origin for live streaming content
  dynamic "origin" {
    for_each = var.enable_live_streaming ? [1] : []
    content {
      domain_name = aws_mediapackage_channel.main[0].hls_ingest[0].ingest_endpoints[0].url
      origin_id   = "MediaPackage-${aws_mediapackage_channel.main[0].id}"
      
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = var.cloudfront_allowed_methods
    cached_methods         = var.cloudfront_cached_methods
    target_origin_id       = var.enable_video_processing ? "S3-${aws_s3_bucket.processed_content[0].id}" : (var.enable_content_delivery ? "S3-${aws_s3_bucket.source_content[0].id}" : "MediaPackage-${aws_mediapackage_channel.main[0].id}")
    compress               = true
    viewer_protocol_policy = var.cloudfront_viewer_protocol_policy

    forwarded_values {
      query_string = var.cloudfront_forward_query_string
      cookies {
        forward = var.cloudfront_forward_cookies
      }
    }

    min_ttl     = var.cloudfront_min_ttl
    default_ttl = var.cloudfront_default_ttl
    max_ttl     = var.cloudfront_max_ttl
  }

  # Cache behavior for live streaming
  dynamic "ordered_cache_behavior" {
    for_each = var.enable_live_streaming ? [1] : []
    content {
      path_pattern           = "/live/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "MediaPackage-${aws_mediapackage_channel.main[0].id}"
      compress               = true
      viewer_protocol_policy = "redirect-to-https"

      forwarded_values {
        query_string = true
        cookies {
          forward = "none"
        }
      }

      min_ttl     = 0
      default_ttl = 5
      max_ttl     = 300
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = var.cloudfront_geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_certificate_arn == null ? true : false
    acm_certificate_arn           = var.cloudfront_certificate_arn
    ssl_support_method            = var.cloudfront_certificate_arn != null ? "sni-only" : null
    minimum_protocol_version      = var.cloudfront_certificate_arn != null ? var.cloudfront_minimum_protocol_version : null
  }

  price_class = var.cloudfront_price_class

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-distribution"
    Purpose = "Content delivery network for media streaming"
  })
}

# Video Processing with MediaConvert
module "video_processing" {
  count  = var.enable_video_processing ? 1 : 0
  source = "./modules/video-processing"

  project_name           = var.project_name
  environment           = var.environment
  source_bucket_name    = aws_s3_bucket.source_content[0].id
  destination_bucket_name = aws_s3_bucket.processed_content[0].id
  mediaconvert_role_arn = var.mediaconvert_role_arn
  job_template_settings = var.mediaconvert_job_template_settings
  mediaconvert_queue_priority = var.mediaconvert_queue_priority
  
  tags = local.common_tags
}

# Live Streaming with MediaLive and MediaPackage
module "live_streaming" {
  count  = var.enable_live_streaming ? 1 : 0
  source = "./modules/live-streaming"

  project_name              = var.project_name
  environment              = var.environment
  medialive_input_type     = var.medialive_input_type
  medialive_input_sources  = var.medialive_input_sources
  medialive_channel_class  = var.medialive_channel_class
  mediapackage_segment_duration = var.mediapackage_segment_duration
  mediapackage_manifest_window = var.mediapackage_manifest_window
  
  # DASH and DRM configuration
  enable_dash              = var.enable_dash
  enable_drm               = var.enable_drm
  drm_system_ids          = var.drm_system_ids
  drm_key_provider_url    = var.drm_key_provider_url
  drm_key_rotation_seconds = var.drm_key_rotation_seconds
  
  # Video and audio descriptions
  video_descriptions      = var.video_descriptions
  audio_descriptions      = var.audio_descriptions
  
  # Monitoring
  enable_cloudwatch_logs  = var.enable_cloudwatch_logs
  log_retention_days      = var.log_retention_days
  
  tags = local.common_tags
}

# MediaPackage Channel (for live streaming)
resource "aws_mediapackage_channel" "main" {
  count       = var.enable_live_streaming ? 1 : 0
  channel_id  = "${var.project_name}-live-channel"
  description = "Live streaming channel for ${var.project_name}"

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-live-channel"
    Purpose = "Live streaming media package channel"
  })
}

# S3 Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "processed_content_policy" {
  count  = var.enable_video_processing && var.enable_content_delivery ? 1 : 0
  bucket = aws_s3_bucket.processed_content[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.processed_content[0].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main[0].arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "source_content_policy" {
  count  = !var.enable_video_processing && var.enable_content_delivery ? 1 : 0
  bucket = aws_s3_bucket.source_content[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.source_content[0].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main[0].arn
          }
        }
      }
    ]
  })
}
