# Variables for Live Streaming Only Example

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "live-streaming-demo"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "enable_drm" {
  description = "Enable DRM protection for live streams"
  type        = bool
  default     = false
}

variable "drm_key_provider_url" {
  description = "URL of the DRM key provider (SPEKE) - required if enable_drm is true"
  type        = string
  default     = null
}
