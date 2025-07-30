# Live Streaming Module - MediaLive + MediaPackage + CloudFront
# Handles live video streaming workflows

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# MediaLive Input Security Group
resource "aws_medialive_input_security_group" "main" {
  whitelist_rules {
    cidr = "0.0.0.0/0"
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-input-security-group"
    Purpose = "MediaLive input security group"
  })
}

# MediaLive Input
resource "aws_medialive_input" "main" {
  name                  = "${var.project_name}-input"
  input_security_groups = [aws_medialive_input_security_group.main.id]
  type                  = var.medialive_input_type

  dynamic "destinations" {
    for_each = var.medialive_input_type == "RTMP_PUSH" ? [1, 2] : []
    content {
      stream_name = "${var.project_name}-stream-${destinations.value}"
    }
  }

  dynamic "sources" {
    for_each = var.medialive_input_sources
    content {
      password_param = sources.value.password_param
      url           = sources.value.url
      username      = sources.value.username
    }
  }

  dynamic "input_devices" {
    for_each = var.medialive_input_type == "INPUT_DEVICE" ? var.input_devices : []
    content {
      id = input_devices.value.id
    }
  }

  dynamic "media_connect_flows" {
    for_each = var.medialive_input_type == "MEDIACONNECT" ? var.media_connect_flows : []
    content {
      flow_arn = media_connect_flows.value.flow_arn
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-input"
    Purpose = "MediaLive input source"
  })
}

# IAM Role for MediaLive
resource "aws_iam_role" "medialive_role" {
  name = "${var.project_name}-medialive-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "medialive.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.project_name}-medialive-role"
    Purpose = "MediaLive service role"
  })
}

# IAM Policy for MediaLive
resource "aws_iam_role_policy" "medialive_policy" {
  name = "${var.project_name}-medialive-policy"
  role = aws_iam_role.medialive_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mediapackage:DescribeChannel",
          "mediapackage:DescribeOriginEndpoint",
          "mediapackage:CreateChannel",
          "mediapackage:CreateOriginEndpoint"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# MediaPackage Channel
resource "aws_mediapackage_channel" "main" {
  channel_id  = "${var.project_name}-channel"
  description = "MediaPackage channel for ${var.project_name}"

  tags = merge(var.tags, {
    Name    = "${var.project_name}-channel"
    Purpose = "MediaPackage channel for live streaming"
  })
}

# MediaPackage Origin Endpoint - HLS
resource "aws_mediapackage_origin_endpoint" "hls" {
  channel_id = aws_mediapackage_channel.main.id
  id         = "${var.project_name}-hls-endpoint"
  description = "HLS origin endpoint for ${var.project_name}"

  hls_package {
    segment_duration_seconds = var.mediapackage_segment_duration
    playlist_window_seconds  = var.mediapackage_manifest_window
    
    dynamic "encryption" {
      for_each = var.enable_drm ? [1] : []
      content {
        encryption_method = "AES_128"
        key_rotation_interval_seconds = var.drm_key_rotation_seconds
        
        speke_key_provider {
          system_ids  = var.drm_system_ids
          url         = var.drm_key_provider_url
          resource_id = "${var.project_name}-hls"
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-hls-endpoint"
    Purpose = "HLS streaming endpoint"
  })
}

# MediaPackage Origin Endpoint - DASH
resource "aws_mediapackage_origin_endpoint" "dash" {
  count       = var.enable_dash ? 1 : 0
  channel_id  = aws_mediapackage_channel.main.id
  id          = "${var.project_name}-dash-endpoint"
  description = "DASH origin endpoint for ${var.project_name}"

  dash_package {
    segment_duration_seconds = var.mediapackage_segment_duration
    manifest_window_seconds  = var.mediapackage_manifest_window
    
    dynamic "encryption" {
      for_each = var.enable_drm ? [1] : []
      content {
        speke_key_provider {
          system_ids  = var.drm_system_ids
          url         = var.drm_key_provider_url
          resource_id = "${var.project_name}-dash"
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-dash-endpoint"
    Purpose = "DASH streaming endpoint"
  })
}

# MediaLive Channel
resource "aws_medialive_channel" "main" {
  name          = "${var.project_name}-channel"
  channel_class = var.medialive_channel_class
  role_arn      = aws_iam_role.medialive_role.arn

  input_specification {
    codec            = var.input_codec
    input_resolution = var.input_resolution
    maximum_bitrate  = var.input_maximum_bitrate
  }

  input_attachments {
    input_attachment_name = "${var.project_name}-input-attachment"
    input_id             = aws_medialive_input.main.id
  }

  destinations {
    id = "${var.project_name}-destination"
    
    media_package_settings {
      channel_id = aws_mediapackage_channel.main.id
    }
  }

  encoder_settings {
    timecode_config {
      source = "EMBEDDED"
    }

    # Audio descriptions
    dynamic "audio_descriptions" {
      for_each = var.audio_descriptions
      content {
        audio_selector_name = audio_descriptions.value.name
        name               = audio_descriptions.value.name
        
        codec_settings {
          aac_settings {
            bitrate         = audio_descriptions.value.bitrate
            coding_mode     = audio_descriptions.value.coding_mode
            input_type      = "NORMAL"
            profile         = "LC"
            raw_format      = "NONE"
            sample_rate     = audio_descriptions.value.sample_rate
            spec            = "MPEG4"
          }
        }
      }
    }

    # Video descriptions
    dynamic "video_descriptions" {
      for_each = var.video_descriptions
      content {
        name   = video_descriptions.value.name
        width  = video_descriptions.value.width
        height = video_descriptions.value.height

        codec_settings {
          h264_settings {
            adaptive_quantization = "HIGH"
            afd_signaling         = "NONE"
            bitrate              = video_descriptions.value.bitrate
            color_metadata       = "INSERT"
            entropy_encoding     = "CABAC"
            flicker_aq          = "ENABLED"
            force_field_pictures = "DISABLED"
            framerate_control   = "SPECIFIED"
            framerate_numerator = video_descriptions.value.framerate_numerator
            framerate_denominator = video_descriptions.value.framerate_denominator
            gop_b_reference     = "DISABLED"
            gop_closed_cadence  = 1
            gop_num_b_frames    = 2
            gop_size            = video_descriptions.value.gop_size
            gop_size_units      = "FRAMES"
            level               = "H264_LEVEL_AUTO"
            look_ahead_rate_control = "MEDIUM"
            max_bitrate         = video_descriptions.value.max_bitrate
            min_i_interval      = 0
            num_ref_frames      = 1
            par_control         = "SPECIFIED"
            par_numerator       = 1
            par_denominator     = 1
            profile             = "MAIN"
            quality_level       = "STANDARD"
            qvbr_quality_level  = 7
            rate_control_mode   = video_descriptions.value.rate_control_mode
            scan_type           = "PROGRESSIVE"
            scene_change_detect = "ENABLED"
            slices              = 1
            spatial_aq          = "ENABLED"
            subgop_length       = "FIXED"
            syntax              = "DEFAULT"
            temporal_aq         = "ENABLED"
            timecode_insertion  = "DISABLED"
          }
        }
      }
    }

    # Output groups
    output_groups {
      name = "${var.project_name}-output-group"
      
      output_group_settings {
        media_package_group_settings {
          destination {
            destination_ref_id = "${var.project_name}-destination"
          }
        }
      }

      dynamic "outputs" {
        for_each = var.video_descriptions
        content {
          output_name = "${outputs.value.name}-output"
          
          output_settings {
            media_package_output_settings {}
          }
          
          video_description_name = outputs.value.name
          audio_description_names = [for audio in var.audio_descriptions : audio.name]
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-channel"
    Purpose = "MediaLive channel for live streaming"
  })
}

# CloudWatch Log Group for MediaLive
resource "aws_cloudwatch_log_group" "medialive" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/medialive/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name    = "${var.project_name}-medialive-logs"
    Purpose = "MediaLive logging"
  })
}

# CloudWatch Log Group for MediaPackage
resource "aws_cloudwatch_log_group" "mediapackage" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/mediapackage/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name    = "${var.project_name}-mediapackage-logs"
    Purpose = "MediaPackage logging"
  })
}
