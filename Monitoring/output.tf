output "workspace_prometheus_arn" {
  
  value       = aws_prometheus_workspace.kpi.arn
}

output "workspace_id" {

  value       = aws_prometheus_workspace.kpi.id
}

output "workspace_prometheus_endpoint" {
 
  value       = aws_prometheus_workspace.kpi.prometheus_endpoint
}

output "workspace_grafana_arn" {
  
  value       = aws_grafana_workspace.kpi.arn
}

output "workspace_grafana_endpoint" {
 
  value       = aws_grafana_workspace.kpi.grafana_endpoint
}
output "workspace_grafana_version" {
  value       = aws_grafana_workspace.kpi.grafana_version
  
}
