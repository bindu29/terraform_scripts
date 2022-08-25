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
