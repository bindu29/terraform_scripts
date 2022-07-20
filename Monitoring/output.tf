output "workspace_arn" {
  
  value       = aws_prometheus_workspace.kpi.arn
}

output "workspace_id" {

  value       = aws_prometheus_workspace.kpi.id
}

output "workspace_prometheus_endpoint" {
 
  value       = aws_prometheus_workspace.kpi.prometheus_endpoint
}
