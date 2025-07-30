# Outputs for Live Streaming Module

# MediaLive Outputs
output "channel_arn" {
  description = "ARN of the MediaLive channel"
  value       = aws_medialive_channel.main.arn
}

output "channel_id" {
  description = "ID of the MediaLive channel"
  value       = aws_medialive_channel.main.id
}

output "channel_name" {
  description = "Name of the MediaLive channel"
  value       = aws_medialive_channel.main.name
}

output "input_id" {
  description = "ID of the MediaLive input"
  value       = aws_medialive_input.main.id
}

output "input_arn" {
  description = "ARN of the MediaLive input"
  value       = aws_medialive_input.main.arn
}

output "input_destinations" {
  description = "Destinations for the MediaLive input"
  value       = aws_medialive_input.main.destinations
  sensitive   = true
}

output "input_security_group_id" {
  description = "ID of the MediaLive input security group"
  value       = aws_medialive_input_security_group.main.id
}

# MediaPackage Outputs
output "mediapackage_channel_id" {
  description = "ID of the MediaPackage channel"
  value       = aws_mediapackage_channel.main.id
}

output "mediapackage_channel_arn" {
  description = "ARN of the MediaPackage channel"
  value       = aws_mediapackage_channel.main.arn
}

output "mediapackage_hls_ingest_endpoints" {
  description = "HLS ingest endpoints for the MediaPackage channel"
  value       = aws_mediapackage_channel.main.hls_ingest
  sensitive   = true
}

output "hls_endpoint_id" {
  description = "ID of the HLS origin endpoint"
  value       = aws_mediapackage_origin_endpoint.hls.id
}

output "hls_endpoint_arn" {
  description = "ARN of the HLS origin endpoint"
  value       = aws_mediapackage_origin_endpoint.hls.arn
}

output "hls_endpoint_url" {
  description = "URL of the HLS origin endpoint"
  value       = aws_mediapackage_origin_endpoint.hls.url
}

output "dash_endpoint_id" {
  description = "ID of the DASH origin endpoint"
  value       = var.enable_dash ? aws_mediapackage_origin_endpoint.dash[0].id : null
}

output "dash_endpoint_arn" {
  description = "ARN of the DASH origin endpoint"
  value       = var.enable_dash ? aws_mediapackage_origin_endpoint.dash[0].arn : null
}

output "dash_endpoint_url" {
  description = "URL of the DASH origin endpoint"
  value       = var.enable_dash ? aws_mediapackage_origin_endpoint.dash[0].url : null
}

# IAM Role Outputs
output "medialive_role_arn" {
  description = "ARN of the MediaLive service role"
  value       = aws_iam_role.medialive_role.arn
}

output "medialive_role_name" {
  description = "Name of the MediaLive service role"
  value       = aws_iam_role.medialive_role.name
}

# CloudWatch Log Groups
output "medialive_log_group_name" {
  description = "Name of the MediaLive CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.medialive[0].name : null
}

output "medialive_log_group_arn" {
  description = "ARN of the MediaLive CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.medialive[0].arn : null
}

output "mediapackage_log_group_name" {
  description = "Name of the MediaPackage CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.mediapackage[0].name : null
}

output "mediapackage_log_group_arn" {
  description = "ARN of the MediaPackage CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.mediapackage[0].arn : null
}

# Streaming URLs and Configuration
output "rtmp_push_urls" {
  description = "RTMP push URLs for streaming (when input type is RTMP_PUSH)"
  value = var.medialive_input_type == "RTMP_PUSH" ? [
    for dest in aws_medialive_input.main.destinations : 
    "rtmp://${dest.url}/${dest.stream_name}"
  ] : null
  sensitive = true
}

output "streaming_configuration" {
  description = "Summary of streaming configuration"
  value = {
    input_type           = var.medialive_input_type
    channel_class        = var.medialive_channel_class
    video_profiles       = [for v in var.video_descriptions : "${v.name} (${v.width}x${v.height})"]
    audio_profiles       = [for a in var.audio_descriptions : a.name]
    hls_enabled         = true
    dash_enabled        = var.enable_dash
    drm_enabled         = var.enable_drm
    segment_duration    = var.mediapackage_segment_duration
    manifest_window     = var.mediapackage_manifest_window
  }
}

# Cost Information
output "estimated_hourly_cost_usd" {
  description = "Estimated hourly cost in USD (approximate)"
  value = {
    medialive_channel = var.medialive_channel_class == "SINGLE_PIPELINE" ? "~$1.50/hour" : "~$3.00/hour"
    mediapackage_requests = "Variable based on viewer requests"
    data_transfer = "Variable based on bandwidth usage"
    note = "Costs are approximate and may vary by region and usage patterns"
  }
}
