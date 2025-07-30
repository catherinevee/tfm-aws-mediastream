# Outputs for Complete Production Example

# Primary URLs
output "cloudfront_distribution_url" {
  description = "CloudFront distribution URL for content delivery"
  value       = module.media_streaming.content_delivery_url
}

output "live_streaming_playback_url" {
  description = "URL for live streaming playback"
  value       = module.media_streaming.live_streaming_playback_url
}

# Storage Information
output "source_content_bucket" {
  description = "S3 bucket for source content"
  value       = module.media_streaming.source_content_bucket_id
}

output "processed_content_bucket" {
  description = "S3 bucket for processed content"
  value       = module.media_streaming.processed_content_bucket_id
}

output "live_content_bucket" {
  description = "S3 bucket for live content"
  value       = module.media_streaming.live_content_bucket_id
}

# Video Processing Information
output "mediaconvert_queue_name" {
  description = "MediaConvert queue name"
  value       = module.media_streaming.video_processing_queue_name
}

output "mediaconvert_job_template_arn" {
  description = "MediaConvert job template ARN"
  value       = module.media_streaming.video_processing_job_template_arn
}

# Live Streaming Information
output "medialive_channel_id" {
  description = "MediaLive channel ID"
  value       = module.media_streaming.live_streaming_channel_id
}

output "mediapackage_channel_id" {
  description = "MediaPackage channel ID"
  value       = module.media_streaming.mediapackage_channel_id
}

# CloudFront Information
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.media_streaming.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.media_streaming.cloudfront_distribution_domain_name
}

# Configuration Summary
output "resource_summary" {
  description = "Summary of created resources"
  value       = module.media_streaming.resource_summary
}

output "configuration_summary" {
  description = "Summary of configuration"
  value       = module.media_streaming.configuration_summary
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value       = module.media_streaming.estimated_monthly_cost_usd
}

# Production Deployment Information
output "deployment_info" {
  description = "Production deployment information"
  value = {
    project_name        = var.project_name
    environment        = var.environment
    region             = var.aws_region
    drm_enabled        = var.enable_drm
    custom_domain      = var.cloudfront_certificate_arn != null
    high_availability  = true
    monitoring_enabled = true
    cost_optimized     = true
    security_level     = "High"
    compliance_ready   = true
  }
}
