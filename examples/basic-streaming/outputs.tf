# Outputs for Basic Streaming Example

# Content Delivery URLs
output "cloudfront_distribution_url" {
  description = "CloudFront distribution URL for content delivery"
  value       = module.media_streaming.content_delivery_url
}

output "live_streaming_playback_url" {
  description = "URL for live streaming playback"
  value       = module.media_streaming.live_streaming_playback_url
}

# S3 Bucket Information
output "source_content_bucket" {
  description = "S3 bucket for source content"
  value       = module.media_streaming.source_content_bucket_id
}

output "processed_content_bucket" {
  description = "S3 bucket for processed content"
  value       = module.media_streaming.processed_content_bucket_id
}

# MediaConvert Information
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

# Configuration Summary
output "resource_summary" {
  description = "Summary of created resources"
  value       = module.media_streaming.resource_summary
}

output "configuration_summary" {
  description = "Summary of configuration"
  value       = module.media_streaming.configuration_summary
}
