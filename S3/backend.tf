# This file is used to declare the backend to store the state the terraform state files. 
# There are various remote backends available but here we are using AWS S3 as the backend.

terraform{
    backend "s3"{

         bucket = "kpi-test-tfstate"
         encrypt = true
         key = "terraform/kpi-test-glue-kafka.tfstate"
         region = "us-east-1"
    }
}
