################# CMK-KMS ####################

# Creation of Aws Kms key 

resource "aws_kms_key" "kpi"{

    description = "kpi-${var.environment}-${var.client}-kms key-managed by Terraform"
    key_usage = "${var.key_usage}"
    customer_master_key_spec = "${var.key_spec}"
    policy = "${var.key_policy}"
    tags = {
        Name = "${var.client}-${var.environment}"
        Owner = "${var.client}"
        Environment = "${var.environment}"
        Type = "${var.pipeline}"
    }
}

# creation of alias 

resource "aws_kms_alias" "kpi" {

    name = "alias/kpi-${lower(var.client)}-${lower(var.environment)}-${lower(var.service)}"
    target_key_id = aws_kms_key.kpi.key_id
  
}