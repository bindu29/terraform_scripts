# This file is used to declare the backend to store the state the terraform state files. 
# There are various remote backends available but here we are using AWS S3 as the backend.

terraform{
    backend "s3"{

         bucket = "kpi-${var.environment}-tfstate"
         encrypt = true
         key = "terraform/kpi-${var.environment}-${var.client}-${var.service}.tfstate"
         region = "${var.region}"
    }
}
