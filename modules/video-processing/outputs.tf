# Outputs for Video Processing Module

output "queue_arn" {
  description = "ARN of the MediaConvert queue"
  value       = aws_media_convert_queue.main.arn
}

output "queue_name" {
  description = "Name of the MediaConvert queue"
  value       = aws_media_convert_queue.main.name
}

output "queue_id" {
  description = "ID of the MediaConvert queue"
  value       = aws_media_convert_queue.main.id
}

output "job_template_arn" {
  description = "ARN of the MediaConvert job template"
  value       = aws_media_convert_job_template.main.arn
}

output "job_template_name" {
  description = "Name of the MediaConvert job template"
  value       = aws_media_convert_job_template.main.name
}

output "service_role_arn" {
  description = "ARN of the MediaConvert service role"
  value       = var.mediaconvert_role_arn != null ? var.mediaconvert_role_arn : aws_iam_role.mediaconvert_role[0].arn
}

output "service_role_name" {
  description = "Name of the MediaConvert service role"
  value       = var.mediaconvert_role_arn != null ? null : aws_iam_role.mediaconvert_role[0].name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function for auto job submission"
  value       = var.enable_auto_job_submission ? aws_lambda_function.job_submitter[0].arn : null
}

output "lambda_function_name" {
  description = "Name of the Lambda function for auto job submission"
  value       = var.enable_auto_job_submission ? aws_lambda_function.job_submitter[0].function_name : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.mediaconvert[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.mediaconvert[0].arn : null
}

output "configuration_summary" {
  description = "Summary of video processing configuration"
  value = {
    queue_name           = aws_media_convert_queue.main.name
    job_template_name    = aws_media_convert_job_template.main.name
    pricing_plan         = var.pricing_plan
    auto_job_submission  = var.enable_auto_job_submission
    cloudwatch_logs      = var.enable_cloudwatch_logs
    source_bucket        = var.source_bucket_name
    destination_bucket   = var.destination_bucket_name
  }
}
