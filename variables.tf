# Variables for AWS Media Streaming Terraform Module

# Project Configuration
variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Feature Toggles
variable "enable_video_processing" {
  description = "Enable video processing with MediaConvert"
  type        = bool
  default     = true
}

variable "enable_live_streaming" {
  description = "Enable live streaming with MediaLive and MediaPackage"
  type        = bool
  default     = true
}

variable "enable_content_delivery" {
  description = "Enable content delivery with CloudFront"
  type        = bool
  default     = true
}

# S3 Configuration
variable "enable_versioning" {
  description = "Enable versioning for S3 buckets"
  type        = bool
  default     = true
}

variable "s3_encryption_algorithm" {
  description = "Server-side encryption algorithm for S3 buckets"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "aws:kms"], var.s3_encryption_algorithm)
    error_message = "S3 encryption algorithm must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for S3 encryption (required if s3_encryption_algorithm is aws:kms)"
  type        = string
  default     = null
}

# CloudFront Configuration
variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "cloudfront_allowed_methods" {
  description = "HTTP methods that CloudFront processes and forwards"
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cloudfront_cached_methods" {
  description = "HTTP methods for which CloudFront caches responses"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cloudfront_viewer_protocol_policy" {
  description = "Protocol policy for viewers"
  type        = string
  default     = "redirect-to-https"
  
  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cloudfront_viewer_protocol_policy)
    error_message = "Viewer protocol policy must be one of: allow-all, https-only, redirect-to-https."
  }
}

variable "cloudfront_forward_query_string" {
  description = "Whether to forward query strings to the origin"
  type        = bool
  default     = false
}

variable "cloudfront_forward_cookies" {
  description = "How to forward cookies to the origin"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["none", "whitelist", "all"], var.cloudfront_forward_cookies)
    error_message = "Forward cookies must be one of: none, whitelist, all."
  }
}

variable "cloudfront_min_ttl" {
  description = "Minimum TTL for CloudFront cache"
  type        = number
  default     = 0
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache"
  type        = number
  default     = 3600
}

variable "cloudfront_max_ttl" {
  description = "Maximum TTL for CloudFront cache"
  type        = number
  default     = 86400
}

variable "cloudfront_geo_restriction_type" {
  description = "Type of geo restriction (none, whitelist, blacklist)"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cloudfront_geo_restriction_type)
    error_message = "Geo restriction type must be one of: none, whitelist, blacklist."
  }
}

variable "cloudfront_geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "cloudfront_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (optional)"
  type        = string
  default     = null
}

variable "cloudfront_minimum_protocol_version" {
  description = "Minimum SSL/TLS protocol version for custom certificate"
  type        = string
  default     = "TLSv1.2_2021"
  
  validation {
    condition = contains([
      "SSLv3", "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", 
      "TLSv1.2_2019", "TLSv1.2_2021"
    ], var.cloudfront_minimum_protocol_version)
    error_message = "Invalid minimum protocol version."
  }
}

# MediaConvert Configuration
variable "mediaconvert_role_arn" {
  description = "IAM role ARN for MediaConvert service"
  type        = string
  default     = null
}

variable "mediaconvert_queue_priority" {
  description = "Priority for MediaConvert queue (-50 to 50)"
  type        = number
  default     = 0
  
  validation {
    condition     = var.mediaconvert_queue_priority >= -50 && var.mediaconvert_queue_priority <= 50
    error_message = "MediaConvert queue priority must be between -50 and 50."
  }
}

variable "mediaconvert_job_template_settings" {
  description = "MediaConvert job template settings"
  type = object({
    output_groups = list(object({
      name = string
      output_group_settings = object({
        type = string
        hls_group_settings = optional(object({
          destination         = string
          segment_length     = optional(number, 10)
          min_segment_length = optional(number, 1)
        }))
        dash_iso_group_settings = optional(object({
          destination         = string
          segment_length     = optional(number, 30)
          fragment_length    = optional(number, 2)
        }))
        file_group_settings = optional(object({
          destination = string
        }))
      })
      outputs = list(object({
        name_modifier = string
        video_description = optional(object({
          codec_settings = object({
            codec = string
            h264_settings = optional(object({
              bitrate              = optional(number, 5000000)
              rate_control_mode    = optional(string, "CBR")
              max_bitrate         = optional(number)
              gop_size            = optional(number, 90)
              gop_size_units      = optional(string, "FRAMES")
              frame_rate_control  = optional(string, "SPECIFIED")
              frame_rate_numerator = optional(number, 30)
              frame_rate_denominator = optional(number, 1)
            }))
            h265_settings = optional(object({
              bitrate              = optional(number, 5000000)
              rate_control_mode    = optional(string, "CBR")
              max_bitrate         = optional(number)
              gop_size            = optional(number, 90)
              gop_size_units      = optional(string, "FRAMES")
              frame_rate_control  = optional(string, "SPECIFIED")
              frame_rate_numerator = optional(number, 30)
              frame_rate_denominator = optional(number, 1)
            }))
          })
          width  = optional(number, 1920)
          height = optional(number, 1080)
        }))
        audio_descriptions = optional(list(object({
          codec_settings = object({
            codec = string
            aac_settings = optional(object({
              bitrate     = optional(number, 128000)
              sample_rate = optional(number, 48000)
            }))
          })
        })), [])
      }))
    }))
  })
  default = {
    output_groups = [
      {
        name = "HLS"
        output_group_settings = {
          type = "HLS_GROUP_SETTINGS"
          hls_group_settings = {
            destination = "s3://destination-bucket/hls/"
          }
        }
        outputs = [
          {
            name_modifier = "_1080p"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate = 5000000
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

# MediaLive Configuration
variable "medialive_input_type" {
  description = "Type of MediaLive input"
  type        = string
  default     = "RTMP_PUSH"
  
  validation {
    condition = contains([
      "UDP_PUSH", "RTP_PUSH", "RTMP_PUSH", "RTMP_PULL", "URL_PULL",
      "MP4_FILE", "MEDIACONNECT", "INPUT_DEVICE", "AWS_CDI"
    ], var.medialive_input_type)
    error_message = "Invalid MediaLive input type."
  }
}

variable "medialive_input_sources" {
  description = "List of input sources for MediaLive"
  type = list(object({
    password_param = optional(string)
    url           = string
    username      = optional(string)
  }))
  default = []
}

variable "medialive_channel_class" {
  description = "MediaLive channel class"
  type        = string
  default     = "SINGLE_PIPELINE"
  
  validation {
    condition     = contains(["STANDARD", "SINGLE_PIPELINE"], var.medialive_channel_class)
    error_message = "MediaLive channel class must be either 'STANDARD' or 'SINGLE_PIPELINE'."
  }
}

# MediaPackage Configuration
variable "mediapackage_segment_duration" {
  description = "Duration of each segment in seconds for MediaPackage"
  type        = number
  default     = 6
  
  validation {
    condition     = var.mediapackage_segment_duration >= 1 && var.mediapackage_segment_duration <= 30
    error_message = "MediaPackage segment duration must be between 1 and 30 seconds."
  }
}

variable "mediapackage_manifest_window" {
  description = "Time window for the live manifest in seconds"
  type        = number
  default     = 60
  
  validation {
    condition     = var.mediapackage_manifest_window >= 30 && var.mediapackage_manifest_window <= 3600
    error_message = "MediaPackage manifest window must be between 30 and 3600 seconds."
  }
}

variable "enable_dash" {
  description = "Enable DASH streaming endpoint"
  type        = bool
  default     = true
}

# DRM Configuration
variable "enable_drm" {
  description = "Enable DRM protection for streams"
  type        = bool
  default     = false
}

variable "drm_system_ids" {
  description = "List of DRM system IDs"
  type        = list(string)
  default     = ["81376844-f976-481e-a84e-cc25d39b0b33"] # Common PSSH system ID
}

variable "drm_key_provider_url" {
  description = "URL of the DRM key provider (SPEKE)"
  type        = string
  default     = null
}

variable "drm_key_rotation_seconds" {
  description = "Key rotation interval in seconds for DRM"
  type        = number
  default     = 300
  
  validation {
    condition     = var.drm_key_rotation_seconds >= 60 && var.drm_key_rotation_seconds <= 3600
    error_message = "DRM key rotation interval must be between 60 and 3600 seconds."
  }
}

# Video and Audio Configuration
variable "video_descriptions" {
  description = "List of video descriptions for encoding"
  type = list(object({
    name                  = string
    width                 = number
    height                = number
    bitrate              = number
    max_bitrate          = optional(number)
    framerate_numerator  = optional(number, 30)
    framerate_denominator = optional(number, 1)
    gop_size             = optional(number, 60)
    rate_control_mode    = optional(string, "CBR")
  }))
  default = [
    {
      name        = "1080p"
      width       = 1920
      height      = 1080
      bitrate     = 5000000
      max_bitrate = 5000000
    },
    {
      name        = "720p"
      width       = 1280
      height      = 720
      bitrate     = 3000000
      max_bitrate = 3000000
    },
    {
      name        = "480p"
      width       = 854
      height      = 480
      bitrate     = 1500000
      max_bitrate = 1500000
    }
  ]
}

variable "audio_descriptions" {
  description = "List of audio descriptions for encoding"
  type = list(object({
    name         = string
    bitrate      = optional(number, 128000)
    sample_rate  = optional(number, 48000)
    coding_mode  = optional(string, "CODING_MODE_2_0")
  }))
  default = [
    {
      name = "audio_1"
    }
  ]
}

# Monitoring and Logging
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
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

# Security Configuration
variable "enable_waf" {
  description = "Enable AWS WAF for CloudFront distribution"
  type        = bool
  default     = false
}

variable "waf_web_acl_id" {
  description = "WAF Web ACL ID to associate with CloudFront (if enable_waf is true)"
  type        = string
  default     = null
}

# Cost Optimization
variable "enable_intelligent_tiering" {
  description = "Enable S3 Intelligent Tiering for cost optimization"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "S3 lifecycle rules for automated cost optimization"
  type = list(object({
    id     = string
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    transition = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = [
    {
      id     = "media_lifecycle"
      status = "Enabled"
      filter = {
        prefix = "media/"
      }
      transition = [
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
}
