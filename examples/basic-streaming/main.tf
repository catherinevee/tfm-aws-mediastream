# Basic Media Streaming Example
# This example demonstrates a simple setup with video processing, live streaming, and content delivery

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

# Basic Media Streaming Module
module "media_streaming" {
  source = "../../"

  project_name = var.project_name
  environment  = var.environment

  # Enable all features for basic streaming
  enable_video_processing = true
  enable_live_streaming   = true
  enable_content_delivery = true

  # S3 Configuration
  enable_versioning        = true
  s3_encryption_algorithm  = "AES256"

  # CloudFront Configuration
  cloudfront_price_class           = "PriceClass_100"
  cloudfront_viewer_protocol_policy = "redirect-to-https"

  # MediaConvert Configuration
  mediaconvert_queue_priority = 0
  mediaconvert_job_template_settings = {
    output_groups = [
      {
        name = "HLS"
        output_group_settings = {
          type = "HLS_GROUP_SETTINGS"
          hls_group_settings = {
            destination = "s3://destination-bucket/hls/"
            segment_length = 10
            min_segment_length = 1
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
                  rate_control_mode = "CBR"
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
                    bitrate = 128000
                    sample_rate = 48000
                  }
                }
              }
            ]
          },
          {
            name_modifier = "_720p"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate = 3000000
                  rate_control_mode = "CBR"
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
                    bitrate = 128000
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

  # MediaLive Configuration
  medialive_input_type    = "RTMP_PUSH"
  medialive_channel_class = "SINGLE_PIPELINE"

  # MediaPackage Configuration
  mediapackage_segment_duration = 6
  mediapackage_manifest_window  = 60

  # Monitoring
  enable_cloudwatch_logs = true
  log_retention_days     = 30

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Example     = "basic-streaming"
    ManagedBy   = "Terraform"
  }
}
