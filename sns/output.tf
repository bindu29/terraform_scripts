output "sns_topic_arn" {
  
  value       = aws_sns_topic.kpi.arn
  
}

output "sns_topic_id" {

  value       = aws_sns_topic.kpi.id
}

output "sns_owner" {
 
  value       = aws_sns_topic.kpi.owner
}
