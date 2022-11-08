#################### s3 #####################

# creation of s3 bucket

resource "aws_s3_bucket" "kpi" {
  bucket = "kpi-${lower(var.client)}-${lower(var.environment)}-raw-datalake"

  tags = {
    Name = "${var.client}-${var.environment}"
    Environment = "${var.environment}"
    owner = "${var.client}"
    Type = "${var.pipeline}"
  }     
}               

# creation of bucket acl

resource "aws_s3_bucket_acl" "kpi" {
  bucket= aws_s3_bucket.kpi.id
  acl    = "${var.acl}"
}

# creation of bucket versioning

resource "aws_s3_bucket_versioning" "kpi" {
  bucket = aws_s3_bucket.kpi.id
  versioning_configuration {
    status = "${var.versioning}"
  }
}

# creation of objects inside bucket

resource "aws_s3_object" "kpi" {
count = length(var.s3_prefixes)
bucket = aws_s3_bucket.kpi.id
key = "${var.s3_prefixes[count.index]}"
}
   

resource "aws_s3_bucket_server_side_encryption_configuration" "kpi" {
  bucket = aws_s3_bucket.kpi.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.kpi.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
