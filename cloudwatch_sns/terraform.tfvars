region = "us-east-1"
client = "bindu"
pipeline = "cdr-pipeline"
environment = "test"
service = "sns"
account_id = "312841606186"
########################################
# Cloudwatch for Kafka
########################################
msk_clustername = "kpi-test-internal-msk"
msk_brokers_list = ["1", "2"]
########################################
# Cloudwatch for Elasticsearch
########################################
es_domainname = "kpi-test-internal-connect"
es_clientid = "312841606186"
########################################
# Cloudwatch for DocumentDB
########################################
docdb_clustername = "kpi-test-internal-docdb-cluster"
########################################
# Cloudwatch for RDS
########################################
rds_clustername = "kpi-test-internal-cdr-1-cluster"
########################################
# Cloudwatch for EC2
########################################
ec2_kafka_instance_list = ["i-0a818dcced8019b1f","i-0866f7b649b74181c"]
ec2_hl7_instance_list = ["i-0866f7b649b74181c","i-0a818dcced8019b1f"]

########################################
# Cloudwatch for SQS
########################################
sqs_queues_list = ["kpi-test-internal-raw-datalake-adt-dead-queue.fifo", "kpi-test-internal-raw-datalake-adt.fifo", "kpi-test-internal-raw-datalake-mdm-dead-queue.fifo"]
