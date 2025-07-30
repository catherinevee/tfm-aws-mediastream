# Variables for Video Processing Module

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "source_bucket_name" {
  description = "Name of the S3 bucket containing source video files"
  type        = string
}

variable "destination_bucket_name" {
  description = "Name of the S3 bucket for processed video files"
  type        = string
}

variable "mediaconvert_role_arn" {
  description = "ARN of IAM role for MediaConvert service (if null, will create one)"
  type        = string
  default     = null
}

variable "job_template_settings" {
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
}

variable "pricing_plan" {
  description = "MediaConvert pricing plan"
  type        = string
  default     = "ON_DEMAND"
  
  validation {
    condition     = contains(["ON_DEMAND", "RESERVED"], var.pricing_plan)
    error_message = "Pricing plan must be either 'ON_DEMAND' or 'RESERVED'."
  }
}

variable "reservation_commitment" {
  description = "Commitment for reserved pricing (only if pricing_plan is RESERVED)"
  type        = string
  default     = "ONE_YEAR"
  
  validation {
    condition     = contains(["ONE_YEAR"], var.reservation_commitment)
    error_message = "Reservation commitment must be 'ONE_YEAR'."
  }
}

variable "reservation_renewal_type" {
  description = "Renewal type for reserved pricing"
  type        = string
  default     = "AUTO_RENEW"
  
  validation {
    condition     = contains(["AUTO_RENEW", "EXPIRE"], var.reservation_renewal_type)
    error_message = "Reservation renewal type must be either 'AUTO_RENEW' or 'EXPIRE'."
  }
}

variable "reserved_slots" {
  description = "Number of reserved slots for reserved pricing"
  type        = number
  default     = 1
  
  validation {
    condition     = var.reserved_slots >= 1 && var.reserved_slots <= 100
    error_message = "Reserved slots must be between 1 and 100."
  }
}

variable "job_template_category" {
  description = "Category for the job template"
  type        = string
  default     = "Video Processing"
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for MediaConvert"
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

variable "enable_auto_job_submission" {
  description = "Enable automatic job submission when files are uploaded to source bucket"
  type        = bool
  default     = false
}

variable "auto_job_trigger_prefix" {
  description = "S3 prefix to trigger automatic job submission"
  type        = string
  default     = "input/"
}

variable "auto_job_trigger_suffix" {
  description = "S3 suffix to trigger automatic job submission"
  type        = string
  default     = ".mp4"
}
