environment = "test"
client = "crisp"
region = "us-east-1"
type = "CDR-pipeline"
acl = "private"
versioning = "Enabled"
service = "s3"
s3_prefixes = [
  "adt/", "oru/", "lab/", "path/", "ccd/", "medications/", "phss/", "ccda/", "empi-consumer/", "ekg/", "rad/", "trans/"
]
