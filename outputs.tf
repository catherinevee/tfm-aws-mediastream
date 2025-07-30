# Outputs for AWS Media Streaming Terraform Module

# S3 Bucket Outputs
output "source_content_bucket_id" {
  description = "ID of the source content S3 bucket"
  value       = var.enable_video_processing || var.enable_content_delivery ? aws_s3_bucket.source_content[0].id : null
}

output "source_content_bucket_arn" {
  description = "ARN of the source content S3 bucket"
  value       = var.enable_video_processing || var.enable_content_delivery ? aws_s3_bucket.source_content[0].arn : null
}

output "source_content_bucket_domain_name" {
  description = "Domain name of the source content S3 bucket"
  value       = var.enable_video_processing || var.enable_content_delivery ? aws_s3_bucket.source_content[0].bucket_domain_name : null
}

output "processed_content_bucket_id" {
  description = "ID of the processed content S3 bucket"
  value       = var.enable_video_processing ? aws_s3_bucket.processed_content[0].id : null
}

output "processed_content_bucket_arn" {
  description = "ARN of the processed content S3 bucket"
  value       = var.enable_video_processing ? aws_s3_bucket.processed_content[0].arn : null
}

output "processed_content_bucket_domain_name" {
  description = "Domain name of the processed content S3 bucket"
  value       = var.enable_video_processing ? aws_s3_bucket.processed_content[0].bucket_domain_name : null
}

output "live_content_bucket_id" {
  description = "ID of the live content S3 bucket"
  value       = var.enable_live_streaming ? aws_s3_bucket.live_content[0].id : null
}

output "live_content_bucket_arn" {
  description = "ARN of the live content S3 bucket"
  value       = var.enable_live_streaming ? aws_s3_bucket.live_content[0].arn : null
}

# CloudFront Distribution Outputs
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = var.enable_content_delivery ? aws_cloudfront_distribution.main[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = var.enable_content_delivery ? aws_cloudfront_distribution.main[0].arn : null
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = var.enable_content_delivery ? aws_cloudfront_distribution.main[0].domain_name : null
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = var.enable_content_delivery ? aws_cloudfront_distribution.main[0].hosted_zone_id : null
}

output "cloudfront_distribution_status" {
  description = "Status of the CloudFront distribution"
  value       = var.enable_content_delivery ? aws_cloudfront_distribution.main[0].status : null
}

# MediaPackage Outputs
output "mediapackage_channel_id" {
  description = "ID of the MediaPackage channel"
  value       = var.enable_live_streaming ? aws_mediapackage_channel.main[0].id : null
}

output "mediapackage_channel_arn" {
  description = "ARN of the MediaPackage channel"
  value       = var.enable_live_streaming ? aws_mediapackage_channel.main[0].arn : null
}

output "mediapackage_hls_ingest_endpoints" {
  description = "HLS ingest endpoints for the MediaPackage channel"
  value       = var.enable_live_streaming ? aws_mediapackage_channel.main[0].hls_ingest : null
  sensitive   = true
}

# Video Processing Module Outputs
output "video_processing_queue_arn" {
  description = "ARN of the MediaConvert queue"
  value       = var.enable_video_processing ? module.video_processing[0].queue_arn : null
}

output "video_processing_queue_name" {
  description = "Name of the MediaConvert queue"
  value       = var.enable_video_processing ? module.video_processing[0].queue_name : null
}

output "video_processing_job_template_arn" {
  description = "ARN of the MediaConvert job template"
  value       = var.enable_video_processing ? module.video_processing[0].job_template_arn : null
}

output "video_processing_role_arn" {
  description = "ARN of the MediaConvert service role"
  value       = var.enable_video_processing ? module.video_processing[0].service_role_arn : null
}

# Live Streaming Module Outputs
output "live_streaming_channel_arn" {
  description = "ARN of the MediaLive channel"
  value       = var.enable_live_streaming ? module.live_streaming[0].channel_arn : null
}

output "live_streaming_channel_id" {
  description = "ID of the MediaLive channel"
  value       = var.enable_live_streaming ? module.live_streaming[0].channel_id : null
}

output "live_streaming_input_id" {
  description = "ID of the MediaLive input"
  value       = var.enable_live_streaming ? module.live_streaming[0].input_id : null
}

output "live_streaming_input_destinations" {
  description = "Destinations for the MediaLive input"
  value       = var.enable_live_streaming ? module.live_streaming[0].input_destinations : null
  sensitive   = true
}

# Security and Access Outputs
output "origin_access_control_id" {
  description = "ID of the CloudFront Origin Access Control"
  value       = var.enable_content_delivery ? aws_cloudfront_origin_access_control.main[0].id : null
}

# Resource URLs and Endpoints
output "content_delivery_url" {
  description = "Primary URL for content delivery"
  value       = var.enable_content_delivery ? "https://${aws_cloudfront_distribution.main[0].domain_name}" : null
}

output "live_streaming_playback_url" {
  description = "URL for live streaming playback"
  value       = var.enable_live_streaming && var.enable_content_delivery ? "https://${aws_cloudfront_distribution.main[0].domain_name}/live/" : null
}

# Cost and Resource Information
output "estimated_monthly_cost_usd" {
  description = "Estimated monthly cost in USD (approximate)"
  value = {
    s3_storage_gb        = "Variable based on content volume"
    cloudfront_requests  = "Variable based on traffic"
    mediaconvert_minutes = var.enable_video_processing ? "Variable based on processing time" : "Not enabled"
    medialive_hours     = var.enable_live_streaming ? "Variable based on streaming hours" : "Not enabled"
    data_transfer_gb    = "Variable based on bandwidth usage"
  }
}

output "resource_summary" {
  description = "Summary of created resources"
  value = {
    s3_buckets = {
      source_content    = var.enable_video_processing || var.enable_content_delivery ? aws_s3_bucket.source_content[0].id : "Not created"
      processed_content = var.enable_video_processing ? aws_s3_bucket.processed_content[0].id : "Not created"
      live_content     = var.enable_live_streaming ? aws_s3_bucket.live_content[0].id : "Not created"
    }
    cloudfront_distribution = var.enable_content_delivery ? aws_cloudfront_distribution.main[0].id : "Not created"
    mediapackage_channel   = var.enable_live_streaming ? aws_mediapackage_channel.main[0].id : "Not created"
    video_processing       = var.enable_video_processing ? "Enabled" : "Disabled"
    live_streaming        = var.enable_live_streaming ? "Enabled" : "Disabled"
    content_delivery      = var.enable_content_delivery ? "Enabled" : "Disabled"
  }
}

# Configuration Information
output "configuration_summary" {
  description = "Summary of module configuration"
  value = {
    project_name = var.project_name
    environment  = var.environment
    region      = data.aws_region.current.name
    features = {
      video_processing  = var.enable_video_processing
      live_streaming   = var.enable_live_streaming
      content_delivery = var.enable_content_delivery
    }
    security = {
      s3_encryption    = var.s3_encryption_algorithm
      versioning      = var.enable_versioning
      public_access   = "Blocked"
      https_only      = var.cloudfront_viewer_protocol_policy == "https-only" || var.cloudfront_viewer_protocol_policy == "redirect-to-https"
    }
  }
}
