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
########################################
# Cloudwatch for Kafka
########################################
variable "msk_clustername" {

    description = "MSK Cluster Name"
    type = string
}
variable "msk_brokers_list" {

     description = "MSK brokers list"
    type = list(string)
}
########################################
# Cloudwatch for Elasticsearch
########################################
variable "es_domainname" {

    description = "Elastic Search Domain name"
    type = string
}
variable "es_clientid" {

    description = "Elastic Search Client ID"
    type = string
}
########################################
# Cloudwatch for Document DB
########################################
variable "docdb_clustername" {

    description = "DocDB Cluster Name"
    type = string
}
########################################
# Cloudwatch for RDS
########################################
variable "rds_clustername" {

    description = "RDS Cluster Name"
    type = string
}
########################################
# Cloudwatch for EC2
########################################
variable "ec2_kafka_instance_list" {

     description = "EC2 kafka resource list"
    type = list(string)
}

variable "ec2_hl7_instance_list" {

     description = "EC2 HL7 resource list"
    type = list(string)
}

########################################
# Cloudwatch for SQS
########################################
variable "sqs_queues_list" {

    description = "SQS queues list"
    type = list(string)
}