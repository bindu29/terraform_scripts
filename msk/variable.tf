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

variable "broker_count" {

    description = "Count of broker instances, should be in multiple of availablity zones"
    type = string
  
}




variable "kafka_versions" {

    description = "Versions of Kafka in MSK brokers"
    type = string
}

variable "server_properties" {

    description = "MSK Broker server properties"
    type = string
}

variable "encryption_type" {

    description = "Type of description"
    type = string
  
}

variable "instance_type" {

    description = "MSK Instances type"
    type = string
  
}

variable "ebs_volume_size" {

    description = "MSK EBS volume size"
    type = number
  
}
