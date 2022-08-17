# This file is used to declare variables which will be further used in our main.tf file (here, s3.tf)
# Values are read from terraform.tfvars file

variable "environment" {
    description = "Delpoyment Environment"
    type = string
}

variable "client" {
    description = "Client Name"
    type = string 
}

variable "region" {
    description = "AWS Region"
    type = string  
}

variable "type" {
    description = "Type of deployment"
    type = string  
}

variable "acl" {
  description = "The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "versioning" {
  description = "versioning configuration."
  type        = string
}

variable "s3_prefixes" {
  description = "prefixes for s3 storage"
  type = list(string)
}

variable "service" {
  description = "services to be deployed"
  type = string
}
