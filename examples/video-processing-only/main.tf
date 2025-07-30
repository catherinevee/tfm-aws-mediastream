# Video Processing Only Example
# This example demonstrates video processing with MediaConvert only

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

# Video Processing Only Module
module "video_processing" {
  source = "../../"

  project_name = var.project_name
  environment  = var.environment

  # Enable only video processing
  enable_video_processing = true
  enable_live_streaming   = false
  enable_content_delivery = true

  # S3 Configuration
  enable_versioning       = true
  s3_encryption_algorithm = "aws:kms"
  kms_key_id             = var.kms_key_id

  # CloudFront Configuration for processed content delivery
  cloudfront_price_class           = "PriceClass_All"
  cloudfront_viewer_protocol_policy = "https-only"
  cloudfront_min_ttl              = 0
  cloudfront_default_ttl          = 86400
  cloudfront_max_ttl              = 31536000

  # Advanced MediaConvert Configuration
  mediaconvert_queue_priority = 10
  mediaconvert_job_template_settings = {
    output_groups = [
      {
        name = "HLS_Adaptive"
        output_group_settings = {
          type = "HLS_GROUP_SETTINGS"
          hls_group_settings = {
            destination        = "s3://destination-bucket/adaptive-hls/"
            segment_length     = 6
            min_segment_length = 1
          }
        }
        outputs = [
          {
            name_modifier = "_4k"
            video_description = {
              codec_settings = {
                codec = "H_265"
                h265_settings = {
                  bitrate              = 15000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 20000000
                  gop_size            = 60
                  frame_rate_numerator = 30
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
                    bitrate     = 256000
                    sample_rate = 48000
                  }
                }
              }
            ]
          },
          {
            name_modifier = "_1080p"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 8000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 10000000
                  gop_size            = 60
                  frame_rate_numerator = 30
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
          },
          {
            name_modifier = "_720p"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 5000000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 6000000
                  gop_size            = 60
                  frame_rate_numerator = 30
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
                    bitrate     = 128000
                    sample_rate = 48000
                  }
                }
              }
            ]
          },
          {
            name_modifier = "_480p"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 2500000
                  rate_control_mode    = "QVBR"
                  max_bitrate         = 3000000
                  gop_size            = 60
                  frame_rate_numerator = 30
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
                    bitrate     = 96000
                    sample_rate = 48000
                  }
                }
              }
            ]
          }
        ]
      },
      {
        name = "MP4_Files"
        output_group_settings = {
          type = "FILE_GROUP_SETTINGS"
          file_group_settings = {
            destination = "s3://destination-bucket/mp4/"
          }
        }
        outputs = [
          {
            name_modifier = "_1080p_mp4"
            video_description = {
              codec_settings = {
                codec = "H_264"
                h264_settings = {
                  bitrate              = 8000000
                  rate_control_mode    = "CBR"
                  gop_size            = 90
                  frame_rate_numerator = 30
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

  # Cost optimization
  enable_intelligent_tiering = true
  lifecycle_rules = [
    {
      id     = "video_content_lifecycle"
      status = "Enabled"
      filter = {
        prefix = "processed/"
      }
      transition = [
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
    }
  ]

  # Monitoring
  enable_cloudwatch_logs = true
  log_retention_days     = 90

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Example     = "video-processing-only"
    UseCase     = "VOD Processing"
    ManagedBy   = "Terraform"
  }
}
