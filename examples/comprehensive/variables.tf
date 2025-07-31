# ==============================================================================
# COMPREHENSIVE MEDIA STREAMING EXAMPLE - INPUT VARIABLES
# ==============================================================================
# This file defines all input variables for the comprehensive media streaming
# example, demonstrating maximum customizability with detailed descriptions,
# validation rules, and production-ready defaults

# ==============================================================================
# CORE PROJECT CONFIGURATION
# ==============================================================================

variable "aws_region" {
  description = "AWS region for deploying media streaming resources"
  type        = string
  default     = "us-east-1"
  validation {
    condition = contains([
      "us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1", "ap-northeast-1"
    ], var.aws_region)
    error_message = "Region must be one of the supported media services regions."
  }
}

variable "project_name" {
  description = "Name of the media streaming project (used for resource naming)"
  type        = string
  default     = "comprehensive-media-stream"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "business_unit" {
  description = "Business unit responsible for the media streaming platform"
  type        = string
  default     = "media-entertainment"
}

# ==============================================================================
# ENHANCED GOVERNANCE AND COMPLIANCE
# ==============================================================================

variable "cost_center" {
  description = "Cost center for billing allocation and financial tracking"
  type        = string
  default     = "media-production"
}

variable "owner" {
  description = "Owner or team responsible for the media streaming infrastructure"
  type        = string
  default     = "media-engineering-team"
}

variable "compliance_framework" {
  description = "Compliance framework requirements for content protection"
  type        = string
  default     = "SOC2"
  validation {
    condition = contains([
      "none", "SOC2", "PCI-DSS", "HIPAA", "GDPR", "FedRAMP", "ISO27001"
    ], var.compliance_framework)
    error_message = "Must be a valid compliance framework."
  }
}

variable "data_classification" {
  description = "Data classification level for media content security"
  type        = string
  default     = "confidential"
  validation {
    condition = contains([
      "public", "internal", "confidential", "restricted"
    ], var.data_classification)
    error_message = "Must be a valid data classification level."
  }
}

variable "backup_required" {
  description = "Whether backup is required for media content (affects lifecycle policies)"
  type        = bool
  default     = true
}

variable "data_retention_policy" {
  description = "Data retention policy identifier for compliance"
  type        = string
  default     = "7-year-retention"
}

# ==============================================================================
# NETWORKING AND SECURITY CONFIGURATION
# ==============================================================================

variable "vpc_name" {
  description = "Name of the VPC to use for media streaming resources"
  type        = string
  default     = "main-vpc"
}

variable "custom_security_group_ids" {
  description = "List of custom security group IDs for MediaLive inputs"
  type        = list(string)
  default     = []
}

variable "medialive_input_security_enabled" {
  description = "Enable input security for MediaLive channels (recommended for production)"
  type        = bool
  default     = true
}

variable "medialive_input_whitelist_cidrs" {
  description = "CIDR blocks allowed to push to MediaLive inputs (empty allows all)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

# ==============================================================================
# FEATURE TOGGLES - MODULAR ARCHITECTURE
# ==============================================================================

variable "enable_video_processing" {
  description = "Enable video processing with MediaConvert for on-demand content"
  type        = bool
  default     = true
}

variable "enable_live_streaming" {
  description = "Enable live streaming with MediaLive and MediaPackage"
  type        = bool
  default     = true
}

variable "enable_content_delivery" {
  description = "Enable content delivery with CloudFront CDN"
  type        = bool
  default     = true
}

# ==============================================================================
# S3 STORAGE CONFIGURATION
# ==============================================================================

variable "enable_versioning" {
  description = "Enable S3 versioning for content protection and rollback capability"
  type        = bool
  default     = true
}

variable "content_retention_days" {
  description = "Number of days to retain source content before deletion"
  type        = number
  default     = 2555  # 7 years for compliance
  validation {
    condition     = var.content_retention_days >= 30 && var.content_retention_days <= 3650
    error_message = "Content retention must be between 30 days and 10 years."
  }
}

variable "processed_content_retention_days" {
  description = "Number of days to retain processed content before deletion"
  type        = number
  default     = 365  # 1 year
  validation {
    condition     = var.processed_content_retention_days >= 30 && var.processed_content_retention_days <= 3650
    error_message = "Processed content retention must be between 30 days and 10 years."
  }
}

variable "enable_intelligent_tiering" {
  description = "Enable S3 Intelligent Tiering for automatic cost optimization"
  type        = bool
  default     = true
}

# ==============================================================================
# CLOUDFRONT CDN CONFIGURATION
# ==============================================================================

variable "cloudfront_price_class" {
  description = "CloudFront price class for global distribution cost optimization"
  type        = string
  default     = "PriceClass_All"
  validation {
    condition = contains([
      "PriceClass_100", "PriceClass_200", "PriceClass_All"
    ], var.cloudfront_price_class)
    error_message = "Must be a valid CloudFront price class."
  }
}

variable "cloudfront_allowed_methods" {
  description = "HTTP methods allowed by CloudFront"
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cloudfront_cached_methods" {
  description = "HTTP methods cached by CloudFront"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cloudfront_acm_certificate_arn" {
  description = "ACM certificate ARN for custom SSL certificate (optional)"
  type        = string
  default     = null
}

variable "cloudfront_aliases" {
  description = "List of custom domain aliases for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache (seconds)"
  type        = number
  default     = 86400  # 24 hours
}

variable "cloudfront_max_ttl" {
  description = "Maximum TTL for CloudFront cache (seconds)"
  type        = number
  default     = 31536000  # 1 year
}

variable "cloudfront_min_ttl" {
  description = "Minimum TTL for CloudFront cache (seconds)"
  type        = number
  default     = 0
}

variable "cloudfront_geo_restriction_type" {
  description = "Type of geographic restriction (none, whitelist, blacklist)"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cloudfront_geo_restriction_type)
    error_message = "Must be none, whitelist, or blacklist."
  }
}

variable "cloudfront_geo_restriction_locations" {
  description = "List of country codes for geographic restrictions"
  type        = list(string)
  default     = []
}

variable "cloudfront_web_acl_id" {
  description = "AWS WAF Web ACL ID for CloudFront protection (optional)"
  type        = string
  default     = null
}

variable "cloudfront_custom_error_responses" {
  description = "Custom error responses for CloudFront"
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  default = [
    {
      error_code            = 404
      response_code         = 404
      response_page_path    = "/404.html"
      error_caching_min_ttl = 300
    },
    {
      error_code            = 403
      response_code         = 403
      response_page_path    = "/403.html"
      error_caching_min_ttl = 300
    }
  ]
}

# ==============================================================================
# VIDEO PROCESSING CONFIGURATION - MEDIACONVERT
# ==============================================================================

variable "mediaconvert_queue_priority" {
  description = "Priority of the MediaConvert queue (0-10, higher is more priority)"
  type        = number
  default     = 5
  validation {
    condition     = var.mediaconvert_queue_priority >= 0 && var.mediaconvert_queue_priority <= 10
    error_message = "MediaConvert queue priority must be between 0 and 10."
  }
}

variable "mediaconvert_queue_pricing_plan" {
  description = "Pricing plan for MediaConvert queue (ON_DEMAND or RESERVED)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "RESERVED"], var.mediaconvert_queue_pricing_plan)
    error_message = "Must be ON_DEMAND or RESERVED."
  }
}

variable "mediaconvert_reserved_queue_slots" {
  description = "Number of reserved queue slots for predictable workloads"
  type        = number
  default     = 0
  validation {
    condition     = var.mediaconvert_reserved_queue_slots >= 0
    error_message = "Reserved queue slots must be non-negative."
  }
}

# ==============================================================================
# LIVE STREAMING CONFIGURATION - MEDIALIVE
# ==============================================================================

variable "medialive_channel_class" {
  description = "MediaLive channel class (STANDARD or SINGLE_PIPELINE)"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "SINGLE_PIPELINE"], var.medialive_channel_class)
    error_message = "Must be STANDARD or SINGLE_PIPELINE."
  }
}

variable "medialive_input_type" {
  description = "MediaLive input type (RTMP_PUSH, RTP_PUSH, UDP_PUSH, etc.)"
  type        = string
  default     = "RTMP_PUSH"
  validation {
    condition = contains([
      "RTMP_PUSH", "RTP_PUSH", "UDP_PUSH", "RTMP_PULL", "URL_PULL"
    ], var.medialive_input_type)
    error_message = "Must be a valid MediaLive input type."
  }
}

# ==============================================================================
# MEDIAPACKAGE CONFIGURATION
# ==============================================================================

variable "enable_hls" {
  description = "Enable HLS packaging for iOS and web playback"
  type        = bool
  default     = true
}

variable "enable_dash" {
  description = "Enable DASH packaging for modern web browsers"
  type        = bool
  default     = true
}

variable "enable_mss" {
  description = "Enable Microsoft Smooth Streaming packaging"
  type        = bool
  default     = false
}

variable "mediapackage_segment_duration" {
  description = "Duration of each media segment in seconds"
  type        = number
  default     = 6
  validation {
    condition     = var.mediapackage_segment_duration >= 1 && var.mediapackage_segment_duration <= 30
    error_message = "Segment duration must be between 1 and 30 seconds."
  }
}

variable "mediapackage_playlist_window" {
  description = "Number of segments to include in the playlist"
  type        = number
  default     = 5
  validation {
    condition     = var.mediapackage_playlist_window >= 3 && var.mediapackage_playlist_window <= 20
    error_message = "Playlist window must be between 3 and 20 segments."
  }
}

# ==============================================================================
# DRM AND CONTENT PROTECTION
# ==============================================================================

variable "enable_drm" {
  description = "Enable DRM protection for premium content"
  type        = bool
  default     = false
}

variable "drm_system_ids" {
  description = "List of DRM system IDs (Widevine, PlayReady, FairPlay)"
  type        = list(string)
  default     = []
}

variable "drm_key_provider_url" {
  description = "URL of the DRM key provider service (SPEKE)"
  type        = string
  default     = null
}

variable "drm_key_rotation_seconds" {
  description = "Key rotation interval in seconds for DRM"
  type        = number
  default     = 3600  # 1 hour
  validation {
    condition     = var.drm_key_rotation_seconds >= 300 && var.drm_key_rotation_seconds <= 86400
    error_message = "Key rotation must be between 5 minutes and 24 hours."
  }
}

# ==============================================================================
# MONITORING AND LOGGING
# ==============================================================================

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for media services"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Must be a valid CloudWatch log retention period."
  }
}

variable "enable_custom_metrics" {
  description = "Enable custom CloudWatch metrics for detailed monitoring"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alerts and notifications (optional)"
  type        = string
  default     = null
}

# ==============================================================================
# COST OPTIMIZATION
# ==============================================================================

variable "enable_spot_pricing" {
  description = "Enable spot pricing for non-critical processing workloads"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable automatic scaling based on queue depth and demand"
  type        = bool
  default     = true
}
