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
variable "instancetype" {
  description = "Instance type for Prometheus instance"
  type = string
  default = null
}
variable "account_id" {

    description = "account id of AWS Service"
    type = string
}
variable "lambda_execution_role_name" {
  description = "The role name of the lambda"
  type        = string
}

################# Variables for SQS ######################

variable "queue_names" {
  description = "names of queues"
  type = list(string) 
}



variable "fifo_queue_status" {
  description = "Boolean designating a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication_status" {
  description = "Enables content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours)"
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)"
  type        = number
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)"
  type        = number
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)"
  type        = number
}
##################### variables for KMS Key ######################

variable "key_usage" {

    description = "intended use of the key"
    type = string
  
}

variable "key_spec" {

    description = "symmetric key or an asymmetric key pair"
    type = string
  
}

variable "key_policy" {

    description = "CMK key policy"
    type = string
  
}
################# Variables for S3 ######################

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
variable "ec2_resource_list" {

    description = "EC2 resource list"
    type = list(string)
  
}
variable "cloudwatch_name" {

    description = "Cloud watch alarm name"
    type = string
  
}