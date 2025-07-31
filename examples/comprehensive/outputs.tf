# ==============================================================================
# COMPREHENSIVE MEDIA STREAMING EXAMPLE - OUTPUTS
# ==============================================================================
# This file defines all outputs for the comprehensive media streaming example,
# providing essential information for integration, monitoring, and operations

# ==============================================================================
# PROJECT AND RESOURCE IDENTIFICATION
# ==============================================================================

output "project_name" {
  description = "Name of the media streaming project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "resource_tags" {
  description = "Common tags applied to all resources"
  value       = module.media_streaming_comprehensive.common_tags
}

# ==============================================================================
# S3 STORAGE OUTPUTS
# ==============================================================================

output "source_bucket_name" {
  description = "Name of the S3 bucket for source media content"
  value       = module.media_streaming_comprehensive.source_bucket_name
}

output "source_bucket_arn" {
  description = "ARN of the source content S3 bucket"
  value       = module.media_streaming_comprehensive.source_bucket_arn
}

output "processed_bucket_name" {
  description = "Name of the S3 bucket for processed media content"
  value       = module.media_streaming_comprehensive.processed_bucket_name
  condition   = var.enable_video_processing
}

output "processed_bucket_arn" {
  description = "ARN of the processed content S3 bucket"
  value       = module.media_streaming_comprehensive.processed_bucket_arn
  condition   = var.enable_video_processing
}

output "s3_encryption_key_arn" {
  description = "ARN of the KMS key used for S3 encryption"
  value       = aws_kms_key.media_encryption.arn
}

output "s3_encryption_key_alias" {
  description = "Alias of the KMS key used for S3 encryption"
  value       = aws_kms_alias.media_encryption.name
}

# ==============================================================================
# CLOUDFRONT CDN OUTPUTS
# ==============================================================================

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.media_streaming_comprehensive.cloudfront_distribution_id
  condition   = var.enable_content_delivery
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = module.media_streaming_comprehensive.cloudfront_distribution_arn
  condition   = var.enable_content_delivery
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.media_streaming_comprehensive.cloudfront_domain_name
  condition   = var.enable_content_delivery
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = module.media_streaming_comprehensive.cloudfront_hosted_zone_id
  condition   = var.enable_content_delivery
}

output "cloudfront_aliases" {
  description = "Custom domain aliases configured for CloudFront"
  value       = var.cloudfront_aliases
  condition   = length(var.cloudfront_aliases) > 0
}

# ==============================================================================
# VIDEO PROCESSING OUTPUTS - MEDIACONVERT
# ==============================================================================

output "mediaconvert_queue_name" {
  description = "Name of the MediaConvert queue"
  value       = module.media_streaming_comprehensive.mediaconvert_queue_name
  condition   = var.enable_video_processing
}

output "mediaconvert_queue_arn" {
  description = "ARN of the MediaConvert queue"
  value       = module.media_streaming_comprehensive.mediaconvert_queue_arn
  condition   = var.enable_video_processing
}

output "mediaconvert_role_arn" {
  description = "ARN of the IAM role used by MediaConvert"
  value       = module.media_streaming_comprehensive.mediaconvert_role_arn
  condition   = var.enable_video_processing
}

output "video_processing_profiles" {
  description = "Video encoding profiles configured for processing"
  value = {
    profiles_count = length(module.media_streaming_comprehensive.video_descriptions)
    resolutions = [
      for profile in module.media_streaming_comprehensive.video_descriptions : 
      "${profile.width}x${profile.height}"
    ]
    bitrates = [
      for profile in module.media_streaming_comprehensive.video_descriptions : 
      "${profile.bitrate / 1000000}Mbps"
    ]
  }
  condition = var.enable_video_processing
}

# ==============================================================================
# LIVE STREAMING OUTPUTS - MEDIALIVE AND MEDIAPACKAGE
# ==============================================================================

output "medialive_channel_id" {
  description = "ID of the MediaLive channel"
  value       = module.media_streaming_comprehensive.medialive_channel_id
  condition   = var.enable_live_streaming
}

output "medialive_channel_arn" {
  description = "ARN of the MediaLive channel"
  value       = module.media_streaming_comprehensive.medialive_channel_arn
  condition   = var.enable_live_streaming
}

output "medialive_input_id" {
  description = "ID of the MediaLive input"
  value       = module.media_streaming_comprehensive.medialive_input_id
  condition   = var.enable_live_streaming
}

output "medialive_input_endpoints" {
  description = "MediaLive input endpoints for streaming"
  value       = module.media_streaming_comprehensive.medialive_input_endpoints
  condition   = var.enable_live_streaming
  sensitive   = true
}

output "mediapackage_channel_id" {
  description = "ID of the MediaPackage channel"
  value       = module.media_streaming_comprehensive.mediapackage_channel_id
  condition   = var.enable_live_streaming
}

output "mediapackage_endpoints" {
  description = "MediaPackage endpoints for different streaming formats"
  value = {
    hls  = var.enable_hls ? module.media_streaming_comprehensive.mediapackage_hls_endpoint : null
    dash = var.enable_dash ? module.media_streaming_comprehensive.mediapackage_dash_endpoint : null
    mss  = var.enable_mss ? module.media_streaming_comprehensive.mediapackage_mss_endpoint : null
  }
  condition = var.enable_live_streaming
}

output "live_streaming_urls" {
  description = "Live streaming playback URLs for different formats"
  value = {
    hls_url  = var.enable_hls && var.enable_content_delivery ? 
      "https://${module.media_streaming_comprehensive.cloudfront_domain_name}/live/index.m3u8" : null
    dash_url = var.enable_dash && var.enable_content_delivery ? 
      "https://${module.media_streaming_comprehensive.cloudfront_domain_name}/live/index.mpd" : null
    mss_url  = var.enable_mss && var.enable_content_delivery ? 
      "https://${module.media_streaming_comprehensive.cloudfront_domain_name}/live/index.ism" : null
  }
  condition = var.enable_live_streaming
}

# ==============================================================================
# SECURITY AND COMPLIANCE OUTPUTS
# ==============================================================================

output "security_summary" {
  description = "Summary of security configurations applied"
  value = {
    encryption_enabled           = true
    kms_key_rotation_enabled    = true
    vpc_isolation_enabled       = local.vpc_id != null
    input_security_enabled      = var.medialive_input_security_enabled
    cloudfront_https_only       = var.enable_content_delivery
    drm_protection_enabled      = var.enable_drm
    compliance_framework        = var.compliance_framework
    data_classification         = var.data_classification
    backup_required            = var.backup_required
  }
}

output "compliance_status" {
  description = "Compliance framework status and requirements"
  value = {
    framework                   = var.compliance_framework
    data_classification         = var.data_classification
    encryption_at_rest         = "AES-256 with KMS"
    encryption_in_transit      = "TLS 1.2+"
    access_logging_enabled     = var.enable_cloudwatch_logs
    audit_trail_retention      = "${var.log_retention_days} days"
    data_retention_policy      = "${var.content_retention_days} days"
    backup_strategy            = var.backup_required ? "Multi-tier with lifecycle" : "Standard"
  }
}

# ==============================================================================
# MONITORING AND OPERATIONAL OUTPUTS
# ==============================================================================

output "monitoring_endpoints" {
  description = "CloudWatch monitoring and logging endpoints"
  value = {
    log_groups = var.enable_cloudwatch_logs ? [
      "/aws/mediaconvert/${var.project_name}",
      "/aws/medialive/${var.project_name}",
      "/aws/mediapackage/${var.project_name}"
    ] : []
    metrics_namespace = "AWS/MediaStreaming/${var.project_name}"
    sns_topic_arn    = var.sns_topic_arn
  }
  condition = var.enable_cloudwatch_logs
}

output "operational_urls" {
  description = "Important URLs for operations and monitoring"
  value = {
    aws_console_mediaconvert = var.enable_video_processing ? 
      "https://${var.aws_region}.console.aws.amazon.com/mediaconvert/home?region=${var.aws_region}#/queues" : null
    aws_console_medialive = var.enable_live_streaming ? 
      "https://${var.aws_region}.console.aws.amazon.com/medialive/home?region=${var.aws_region}#/channels" : null
    aws_console_cloudfront = var.enable_content_delivery ? 
      "https://console.aws.amazon.com/cloudfront/home#/distributions" : null
    aws_console_s3 = "https://s3.console.aws.amazon.com/s3/home?region=${var.aws_region}"
  }
}

# ==============================================================================
# COST OPTIMIZATION OUTPUTS
# ==============================================================================

output "cost_optimization_summary" {
  description = "Summary of cost optimization features enabled"
  value = {
    s3_lifecycle_policies_enabled    = true
    s3_intelligent_tiering_enabled   = var.enable_intelligent_tiering
    cloudfront_compression_enabled   = var.enable_content_delivery
    mediaconvert_reserved_capacity   = var.mediaconvert_reserved_queue_slots
    spot_pricing_enabled            = var.enable_spot_pricing
    auto_scaling_enabled            = var.enable_auto_scaling
    cloudfront_price_class          = var.cloudfront_price_class
  }
}

output "estimated_monthly_costs" {
  description = "Estimated monthly costs breakdown (USD, approximate)"
  value = {
    note = "Costs are estimates based on typical usage patterns and current AWS pricing"
    s3_storage = "Variable based on content volume and access patterns"
    cloudfront = "Variable based on data transfer and requests"
    mediaconvert = var.enable_video_processing ? 
      "Variable based on processing minutes and output formats" : "Not enabled"
    medialive = var.enable_live_streaming ? 
      "Variable based on channel hours and input/output configuration" : "Not enabled"
    mediapackage = var.enable_live_streaming ? 
      "Variable based on packaging requests and data transfer" : "Not enabled"
    data_transfer = "Variable based on global distribution and viewer location"
  }
}

# ==============================================================================
# INTEGRATION AND DEVELOPMENT OUTPUTS
# ==============================================================================

output "api_endpoints" {
  description = "API endpoints for integration with applications"
  value = {
    s3_upload_endpoint = "https://${module.media_streaming_comprehensive.source_bucket_name}.s3.${var.aws_region}.amazonaws.com"
    cloudfront_api_endpoint = var.enable_content_delivery ? 
      "https://${module.media_streaming_comprehensive.cloudfront_domain_name}" : null
    mediaconvert_endpoint = var.enable_video_processing ? 
      "https://mediaconvert.${var.aws_region}.amazonaws.com" : null
  }
}

output "sdk_configuration" {
  description = "Configuration parameters for AWS SDK integration"
  value = {
    region = var.aws_region
    mediaconvert_queue = var.enable_video_processing ? 
      module.media_streaming_comprehensive.mediaconvert_queue_name : null
    mediaconvert_role = var.enable_video_processing ? 
      module.media_streaming_comprehensive.mediaconvert_role_arn : null
    source_bucket = module.media_streaming_comprehensive.source_bucket_name
    processed_bucket = var.enable_video_processing ? 
      module.media_streaming_comprehensive.processed_bucket_name : null
    kms_key_id = aws_kms_key.media_encryption.key_id
  }
}

# ==============================================================================
# DEPLOYMENT VERIFICATION OUTPUTS
# ==============================================================================

output "deployment_verification" {
  description = "Deployment verification checklist and status"
  value = {
    timestamp = timestamp()
    features_enabled = {
      video_processing = var.enable_video_processing
      live_streaming   = var.enable_live_streaming
      content_delivery = var.enable_content_delivery
    }
    security_features = {
      encryption_enabled = true
      vpc_isolation     = local.vpc_id != null
      input_security    = var.medialive_input_security_enabled
      drm_protection    = var.enable_drm
    }
    monitoring_enabled = var.enable_cloudwatch_logs
    compliance_ready   = var.compliance_framework != "none"
    production_ready   = var.environment == "prod"
  }
}

# ==============================================================================
# TROUBLESHOOTING AND SUPPORT OUTPUTS
# ==============================================================================

output "troubleshooting_info" {
  description = "Information for troubleshooting and support"
  value = {
    module_version = "comprehensive-v1.0"
    terraform_version = ">=1.0"
    aws_provider_version = "~>5.0"
    deployment_region = var.aws_region
    support_resources = {
      documentation = "https://docs.aws.amazon.com/media-services/"
      terraform_registry = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs"
      aws_support = "https://console.aws.amazon.com/support/home"
    }
  }
}
