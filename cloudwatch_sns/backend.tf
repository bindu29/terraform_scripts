# This file is used to declare the backend to store the state the terraform state files.
# There are various remote backends available but here we are using AWS S3 as the backend.

terraform{
    backend "s3"{

         bucket = "kpi-161674638527-terraform-e1"
         encrypt = true
         key = "terraform/glue/kpi-test-cloudwatch_sns.tfstate"
         region = "us-east-1"
         profile = "root"
    }
}