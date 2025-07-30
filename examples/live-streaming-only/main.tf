# Live Streaming Only Example
# This example demonstrates live streaming with MediaLive and MediaPackage only

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Live Streaming Only Module
module "live_streaming" {
  source = "../../"

  project_name = var.project_name
  environment  = var.environment

  # Enable only live streaming
  enable_video_processing = false
  enable_live_streaming   = true
  enable_content_delivery = true

  # S3 Configuration for live content storage
  enable_versioning       = false # Not needed for live streaming
  s3_encryption_algorithm = "AES256"

  # CloudFront Configuration optimized for live streaming
  cloudfront_price_class           = "PriceClass_All"
  cloudfront_viewer_protocol_policy = "https-only"
  cloudfront_min_ttl              = 0
  cloudfront_default_ttl          = 5     # Short TTL for live content
  cloudfront_max_ttl              = 300   # Maximum 5 minutes for live

  # MediaLive Configuration for professional live streaming
  medialive_input_type    = "RTMP_PUSH"
  medialive_channel_class = "STANDARD" # Dual pipeline for redundancy

  # MediaPackage Configuration optimized for low latency
  mediapackage_segment_duration = 2  # 2-second segments for lower latency
  mediapackage_manifest_window  = 30 # 30-second manifest window

  # Enable DASH streaming
  enable_dash = true

  # DRM Configuration (optional - set enable_drm to true if needed)
  enable_drm = var.enable_drm
  drm_system_ids = var.enable_drm ? [
    "edef8ba9-79d6-4ace-a3c8-27dcd51d21ed", # Widevine
    "9a04f079-9840-4286-ab92-e65be0885f95", # PlayReady
    "94ce86fb-07ff-4f43-adb8-93d2fa968ca2"  # FairPlay
  ] : []
  drm_key_provider_url     = var.drm_key_provider_url
  drm_key_rotation_seconds = 300

  # Advanced video encoding profiles for live streaming
  video_descriptions = [
    {
      name                  = "1080p60"
      width                 = 1920
      height                = 1080
      bitrate              = 6000000
      max_bitrate          = 8000000
      framerate_numerator  = 60
      framerate_denominator = 1
      gop_size             = 120 # 2 seconds at 60fps
      rate_control_mode    = "CBR"
    },
    {
      name                  = "720p60"
      width                 = 1280
      height                = 720
      bitrate              = 4000000
      max_bitrate          = 5000000
      framerate_numerator  = 60
      framerate_denominator = 1
      gop_size             = 120
      rate_control_mode    = "CBR"
    },
    {
      name                  = "480p30"
      width                 = 854
      height                = 480
      bitrate              = 1500000
      max_bitrate          = 2000000
      framerate_numerator  = 30
      framerate_denominator = 1
      gop_size             = 60
      rate_control_mode    = "CBR"
    }
  ]

  # Audio configuration for live streaming
  audio_descriptions = [
    {
      name         = "stereo_audio"
      bitrate      = 192000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_2_0"
    }
  ]

  # Monitoring and alerting
  enable_cloudwatch_logs = true
  log_retention_days     = 14 # Shorter retention for live streaming logs

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Example     = "live-streaming-only"
    UseCase     = "Live Broadcasting"
    Latency     = "Low"
    ManagedBy   = "Terraform"
  }
}
