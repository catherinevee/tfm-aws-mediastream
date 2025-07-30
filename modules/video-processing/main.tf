# Video Processing Module - MediaConvert + S3 + CloudFront
# Handles video transcoding and processing workflows

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

# IAM Role for MediaConvert Service
resource "aws_iam_role" "mediaconvert_role" {
  count = var.mediaconvert_role_arn == null ? 1 : 0
  name  = "${var.project_name}-mediaconvert-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.project_name}-mediaconvert-role"
    Purpose = "MediaConvert service role"
  })
}

# IAM Policy for MediaConvert Role
resource "aws_iam_role_policy" "mediaconvert_policy" {
  count = var.mediaconvert_role_arn == null ? 1 : 0
  name  = "${var.project_name}-mediaconvert-policy"
  role  = aws_iam_role.mediaconvert_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::${var.source_bucket_name}/*",
          "arn:aws:s3:::${var.destination_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.source_bucket_name}",
          "arn:aws:s3:::${var.destination_bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# MediaConvert Queue
resource "aws_media_convert_queue" "main" {
  name         = "${var.project_name}-queue"
  description  = "MediaConvert queue for ${var.project_name}"
  pricing_plan = var.pricing_plan
  status       = "ACTIVE"

  dynamic "reservation_plan_settings" {
    for_each = var.pricing_plan == "RESERVED" ? [1] : []
    content {
      commitment      = var.reservation_commitment
      renewal_type    = var.reservation_renewal_type
      reserved_slots  = var.reserved_slots
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-queue"
    Purpose = "Video processing queue"
  })
}

# MediaConvert Job Template
resource "aws_media_convert_job_template" "main" {
  name        = "${var.project_name}-job-template"
  description = "Job template for ${var.project_name} video processing"
  category    = var.job_template_category
  queue       = aws_media_convert_queue.main.arn

  settings_json = jsonencode({
    OutputGroups = [
      for group in var.job_template_settings.output_groups : {
        Name = group.name
        OutputGroupSettings = {
          Type = group.output_group_settings.type
          HlsGroupSettings = group.output_group_settings.hls_group_settings != null ? {
            Destination        = replace(group.output_group_settings.hls_group_settings.destination, "destination-bucket", var.destination_bucket_name)
            SegmentLength     = group.output_group_settings.hls_group_settings.segment_length
            MinSegmentLength  = group.output_group_settings.hls_group_settings.min_segment_length
          } : null
          DashIsoGroupSettings = group.output_group_settings.dash_iso_group_settings != null ? {
            Destination     = replace(group.output_group_settings.dash_iso_group_settings.destination, "destination-bucket", var.destination_bucket_name)
            SegmentLength   = group.output_group_settings.dash_iso_group_settings.segment_length
            FragmentLength  = group.output_group_settings.dash_iso_group_settings.fragment_length
          } : null
          FileGroupSettings = group.output_group_settings.file_group_settings != null ? {
            Destination = replace(group.output_group_settings.file_group_settings.destination, "destination-bucket", var.destination_bucket_name)
          } : null
        }
        Outputs = [
          for output in group.outputs : {
            NameModifier = output.name_modifier
            VideoDescription = output.video_description != null ? {
              CodecSettings = {
                Codec = output.video_description.codec_settings.codec
                H264Settings = output.video_description.codec_settings.h264_settings != null ? {
                  Bitrate             = output.video_description.codec_settings.h264_settings.bitrate
                  RateControlMode     = output.video_description.codec_settings.h264_settings.rate_control_mode
                  MaxBitrate         = output.video_description.codec_settings.h264_settings.max_bitrate
                  GopSize            = output.video_description.codec_settings.h264_settings.gop_size
                  GopSizeUnits       = output.video_description.codec_settings.h264_settings.gop_size_units
                  FramerateControl   = output.video_description.codec_settings.h264_settings.frame_rate_control
                  FramerateNumerator = output.video_description.codec_settings.h264_settings.frame_rate_numerator
                  FramerateDenominator = output.video_description.codec_settings.h264_settings.frame_rate_denominator
                } : null
                H265Settings = output.video_description.codec_settings.h265_settings != null ? {
                  Bitrate             = output.video_description.codec_settings.h265_settings.bitrate
                  RateControlMode     = output.video_description.codec_settings.h265_settings.rate_control_mode
                  MaxBitrate         = output.video_description.codec_settings.h265_settings.max_bitrate
                  GopSize            = output.video_description.codec_settings.h265_settings.gop_size
                  GopSizeUnits       = output.video_description.codec_settings.h265_settings.gop_size_units
                  FramerateControl   = output.video_description.codec_settings.h265_settings.frame_rate_control
                  FramerateNumerator = output.video_description.codec_settings.h265_settings.frame_rate_numerator
                  FramerateDenominator = output.video_description.codec_settings.h265_settings.frame_rate_denominator
                } : null
              }
              Width  = output.video_description.width
              Height = output.video_description.height
            } : null
            AudioDescriptions = [
              for audio in output.audio_descriptions : {
                CodecSettings = {
                  Codec = audio.codec_settings.codec
                  AacSettings = audio.codec_settings.aac_settings != null ? {
                    Bitrate    = audio.codec_settings.aac_settings.bitrate
                    SampleRate = audio.codec_settings.aac_settings.sample_rate
                  } : null
                }
              }
            ]
          }
        ]
      }
    ]
    TimecodeConfig = {
      Source = "ZEROBASED"
    }
  })

  tags = merge(var.tags, {
    Name    = "${var.project_name}-job-template"
    Purpose = "Video processing job template"
  })
}

# CloudWatch Log Group for MediaConvert
resource "aws_cloudwatch_log_group" "mediaconvert" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/mediaconvert/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name    = "${var.project_name}-mediaconvert-logs"
    Purpose = "MediaConvert logging"
  })
}

# Lambda Function for Job Submission (Optional)
resource "aws_lambda_function" "job_submitter" {
  count            = var.enable_auto_job_submission ? 1 : 0
  filename         = data.archive_file.job_submitter_zip[0].output_path
  function_name    = "${var.project_name}-mediaconvert-job-submitter"
  role            = aws_iam_role.lambda_role[0].arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60
  source_code_hash = data.archive_file.job_submitter_zip[0].output_base64sha256

  environment {
    variables = {
      JOB_TEMPLATE_NAME = aws_media_convert_job_template.main.name
      QUEUE_NAME       = aws_media_convert_queue.main.name
      ROLE_ARN         = var.mediaconvert_role_arn != null ? var.mediaconvert_role_arn : aws_iam_role.mediaconvert_role[0].arn
    }
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-job-submitter"
    Purpose = "Automatic MediaConvert job submission"
  })
}

# Lambda function code
data "archive_file" "job_submitter_zip" {
  count       = var.enable_auto_job_submission ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/job_submitter.zip"
  
  source {
    content = templatefile("${path.module}/job_submitter.py", {
      job_template_name = aws_media_convert_job_template.main.name
      queue_name       = aws_media_convert_queue.main.name
    })
    filename = "index.py"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  count = var.enable_auto_job_submission ? 1 : 0
  name  = "${var.project_name}-lambda-mediaconvert-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.project_name}-lambda-role"
    Purpose = "Lambda execution role for MediaConvert jobs"
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  count = var.enable_auto_job_submission ? 1 : 0
  name  = "${var.project_name}-lambda-mediaconvert-policy"
  role  = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "mediaconvert:CreateJob",
          "mediaconvert:GetJob",
          "mediaconvert:ListJobs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = var.mediaconvert_role_arn != null ? var.mediaconvert_role_arn : aws_iam_role.mediaconvert_role[0].arn
      }
    ]
  })
}

# S3 Event Notification for Auto Job Submission
resource "aws_s3_bucket_notification" "source_bucket_notification" {
  count  = var.enable_auto_job_submission ? 1 : 0
  bucket = var.source_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.job_submitter[0].arn
    events             = ["s3:ObjectCreated:*"]
    filter_prefix      = var.auto_job_trigger_prefix
    filter_suffix      = var.auto_job_trigger_suffix
  }

  depends_on = [aws_lambda_permission.allow_s3[0]]
}

# Lambda Permission for S3
resource "aws_lambda_permission" "allow_s3" {
  count         = var.enable_auto_job_submission ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.job_submitter[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.source_bucket_name}"
}
