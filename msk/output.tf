output "MSK_plaintext_Endpoint" {

    value = aws_msk_cluster.kpi.bootstrap_brokers
  
}

output "MSK_TLS_Endpoint" {

    value = aws_msk_cluster.kpi.bootstrap_brokers_tls
  
}

output "MSK_cluster_current_version" {

    value = aws_msk_cluster.kpi.current_version
  
}

output "Encryption_info" {

    value = aws_msk_cluster.kpi.encryption_info.0.encryption_at_rest_kms_key_arn
  
}

output "Zookeeper_connection_string" {

    value = aws_msk_cluster.kpi.zookeeper_connect_string
  
}

output "Zookeeper_connection_tls_string" {

    value = aws_msk_cluster.kpi.zookeeper_connect_string_tls
  
}
