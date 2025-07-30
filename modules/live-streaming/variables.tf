# Variables for Live Streaming Module

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

# MediaLive Input Configuration
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

variable "input_devices" {
  description = "List of input devices for MediaLive (when input type is INPUT_DEVICE)"
  type = list(object({
    id = string
  }))
  default = []
}

variable "media_connect_flows" {
  description = "List of MediaConnect flows (when input type is MEDIACONNECT)"
  type = list(object({
    flow_arn = string
  }))
  default = []
}

# MediaLive Channel Configuration
variable "medialive_channel_class" {
  description = "MediaLive channel class"
  type        = string
  default     = "SINGLE_PIPELINE"
  
  validation {
    condition     = contains(["STANDARD", "SINGLE_PIPELINE"], var.medialive_channel_class)
    error_message = "MediaLive channel class must be either 'STANDARD' or 'SINGLE_PIPELINE'."
  }
}

variable "input_codec" {
  description = "Input codec for MediaLive channel"
  type        = string
  default     = "AVC"
  
  validation {
    condition     = contains(["MPEG2", "AVC", "HEVC"], var.input_codec)
    error_message = "Input codec must be one of: MPEG2, AVC, HEVC."
  }
}

variable "input_resolution" {
  description = "Input resolution for MediaLive channel"
  type        = string
  default     = "HD"
  
  validation {
    condition     = contains(["SD", "HD", "UHD"], var.input_resolution)
    error_message = "Input resolution must be one of: SD, HD, UHD."
  }
}

variable "input_maximum_bitrate" {
  description = "Maximum bitrate for MediaLive input"
  type        = string
  default     = "MAX_20_MBPS"
  
  validation {
    condition = contains([
      "MAX_10_MBPS", "MAX_20_MBPS", "MAX_50_MBPS"
    ], var.input_maximum_bitrate)
    error_message = "Input maximum bitrate must be one of: MAX_10_MBPS, MAX_20_MBPS, MAX_50_MBPS."
  }
}

# Video Configuration
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

# Audio Configuration
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

# Monitoring and Logging
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for MediaLive and MediaPackage"
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

# Advanced Configuration
variable "enable_input_loss_behavior" {
  description = "Enable input loss behavior configuration"
  type        = bool
  default     = true
}

variable "input_loss_image_uri" {
  description = "S3 URI for input loss slate image"
  type        = string
  default     = null
}

variable "enable_scte35" {
  description = "Enable SCTE-35 ad insertion markers"
  type        = bool
  default     = false
}

variable "scte35_behavior" {
  description = "SCTE-35 behavior configuration"
  type        = string
  default     = "NO_PASSTHROUGH"
  
  validation {
    condition     = contains(["NO_PASSTHROUGH", "PASSTHROUGH"], var.scte35_behavior)
    error_message = "SCTE-35 behavior must be either 'NO_PASSTHROUGH' or 'PASSTHROUGH'."
  }
}
