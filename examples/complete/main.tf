# Complete Media Streaming Example
# This example demonstrates a full-featured production setup with DRM, monitoring, and advanced configurations

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

# Complete Media Streaming Module with all features
module "media_streaming" {
  source = "../../"

  project_name = var.project_name
  environment  = var.environment

  # Enable all features
  enable_video_processing = true
  enable_live_streaming   = true
  enable_content_delivery = true

  # S3 Configuration with KMS encryption
  enable_versioning       = true
  s3_encryption_algorithm = "aws:kms"
  kms_key_id             = var.kms_key_id

  # CloudFront Configuration with custom domain
  cloudfront_price_class           = "PriceClass_All"
  cloudfront_viewer_protocol_policy = "https-only"
  cloudfront_certificate_arn       = var.cloudfront_certificate_arn
  cloudfront_minimum_protocol_version = "TLSv1.2_2021"
  cloudfront_geo_restriction_type  = "whitelist"
  cloudfront_geo_restriction_locations = ["US", "CA", "GB", "DE", "FR", "JP", "AU"]

  # Advanced MediaConvert Configuration
  mediaconvert_queue_priority = 10
  mediaconvert_job_template_settings = {
    output_groups = [
      {
        name = "HLS_Adaptive_Streaming"
        output_group_settings = {
          type = "HLS_GROUP_SETTINGS"
          hls_group_settings = {
            destination        = "s3://destination-bucket/adaptive-hls/"
            segment_length     = 4
            min_segment_length = 1
          }
        }
        outputs = [
          {
            name_modifier = "_4k_hevc"
            video_description = {
              codec_settings = {
                codec = "H_265"
                h265_settings = {
                  bitrate              = 20000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 25000000
                  gop_size            = 120
                  frame_rate_numerator = 60
                  frame_rate_denominator = 1
                }
              }
              width  = 3840
              height = 2160
            }
            audio_descriptions = [
              {
                codec_settings = {
                  codec = "AAC"
                  aac_settings = {
                    bitrate     = 320000
                    sample_rate = 48000
                  }
                }
              }
            ]
          },
          {
            name_modifier = "_1080p60"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 10000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 12000000
                  gop_size            = 120
                  frame_rate_numerator = 60
                  frame_rate_denominator = 1
                }
              }
              width  = 1920
              height = 1080
            }
            audio_descriptions = [
              {
                codec_settings = {
                  codec = "AAC"
                  aac_settings = {
                    bitrate     = 256000
                    sample_rate = 48000
                  }
                }
              }
            ]
          },
          {
            name_modifier = "_720p30"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 5000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 6000000
                  gop_size            = 60
                  frame_rate_numerator = 30
                  frame_rate_denominator = 1
                }
              }
              width  = 1280
              height = 720
            }
            audio_descriptions = [
              {
                codec_settings = {
                  codec = "AAC"
                  aac_settings = {
                    bitrate     = 192000
                    sample_rate = 48000
                  }
                }
              }
            ]
          },
          {
            name_modifier = "_480p30"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 2000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 2500000
                  gop_size            = 60
                  frame_rate_numerator = 30
                  frame_rate_denominator = 1
                }
              }
              width  = 854
              height = 480
            }
            audio_descriptions = [
              {
                codec_settings = {
                  codec = "AAC"
                  aac_settings = {
                    bitrate     = 128000
                    sample_rate = 48000
                  }
                }
              }
            ]
          }
        ]
      },
      {
        name = "DASH_Streaming"
        output_group_settings = {
          type = "DASH_ISO_GROUP_SETTINGS"
          dash_iso_group_settings = {
            destination      = "s3://destination-bucket/dash/"
            segment_length   = 4
            fragment_length  = 2
          }
        }
        outputs = [
          {
            name_modifier = "_1080p_dash"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 8000000
                  rate_control_mode    = "CBR"
                  gop_size            = 60
                  frame_rate_numerator = 30
                  frame_rate_denominator = 1
                }
              }
              width  = 1920
              height = 1080
            }
            audio_descriptions = [
              {
                codec_settings = {
                  codec = "AAC"
                  aac_settings = {
                    bitrate     = 192000
                    sample_rate = 48000
                  }
                }
              }
            ]
          }
        ]
      }
    ]
  }

  # Professional Live Streaming Configuration
  medialive_input_type    = "RTMP_PUSH"
  medialive_channel_class = "STANDARD" # Dual pipeline for redundancy

  # Low latency live streaming
  mediapackage_segment_duration = 2
  mediapackage_manifest_window  = 20

  # Enable DASH and DRM
  enable_dash = true
  enable_drm  = var.enable_drm
  drm_system_ids = var.enable_drm ? [
    "edef8ba9-79d6-4ace-a3c8-27dcd51d21ed", # Widevine
    "9a04f079-9840-4286-ab92-e65be0885f95", # PlayReady
    "94ce86fb-07ff-4f43-adb8-93d2fa968ca2"  # FairPlay
  ] : []
  drm_key_provider_url     = var.drm_key_provider_url
  drm_key_rotation_seconds = 180 # 3 minutes

  # Professional video profiles
  video_descriptions = [
    {
      name                  = "1080p60_premium"
      width                 = 1920
      height                = 1080
      bitrate              = 8000000
      max_bitrate          = 10000000
      framerate_numerator  = 60
      framerate_denominator = 1
      gop_size             = 120
      rate_control_mode    = "CBR"
    },
    {
      name                  = "720p60_standard"
      width                 = 1280
      height                = 720
      bitrate              = 5000000
      max_bitrate          = 6000000
      framerate_numerator  = 60
      framerate_denominator = 1
      gop_size             = 120
      rate_control_mode    = "CBR"
    },
    {
      name                  = "480p30_mobile"
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

  # High-quality audio
  audio_descriptions = [
    {
      name         = "stereo_hq"
      bitrate      = 256000
      sample_rate  = 48000
      coding_mode  = "CODING_MODE_2_0"
    }
  ]

  # Advanced monitoring and logging
  enable_cloudwatch_logs = true
  log_retention_days     = 90

  # Cost optimization
  enable_intelligent_tiering = true
  lifecycle_rules = [
    {
      id     = "media_content_lifecycle"
      status = "Enabled"
      filter = {
        prefix = "processed/"
      }
      transition = [
        {
          days          = 7
          storage_class = "STANDARD_IA"
        },
        {
          days          = 30
          storage_class = "GLACIER"
        },
        {
          days          = 90
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    },
    {
      id     = "live_content_cleanup"
      status = "Enabled"
      filter = {
        prefix = "live/"
      }
      expiration = {
        days = 7 # Clean up live segments after 7 days
      }
    }
  ]

  # Comprehensive tagging
  tags = {
    Project      = var.project_name
    Environment  = var.environment
    Example      = "complete-production"
    UseCase      = "Professional Media Streaming"
    Tier         = "Premium"
    Monitoring   = "Enhanced"
    Security     = "High"
    Compliance   = "SOC2"
    ManagedBy    = "Terraform"
    Owner        = "MediaEngineering"
    CostCenter   = "Engineering"
    Application  = "StreamingPlatform"
  }
}
