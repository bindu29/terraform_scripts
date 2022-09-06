variable "region" {

    description = "Region of AWS Service"
    type = string
}

variable "client" {

    description = "Client Name"
    type = string
  
}
variable "environment" {

    description = "Environment value"
    type = string
  
}

variable "pipeline" {

    description = "Name of the pipeline"
    type = string
  
}

variable "service" {

    description = "Service name which are deploying"
    type = string
  
}
variable "account_id" {

    description = "account id of AWS Service"
    type = string
}
variable "kafka_clustername" {

    description = "Kafka Cluster Name"
    type = string
}
variable "es_domainname" {

    description = "Elastic Search Domain name"
    type = string
}
variable "es_clientid" {

    description = "Elastic Search Client ID"
    type = string
}
variable "docdb_clustername" {

    description = "DocDB Cluster Name"
    type = string
}