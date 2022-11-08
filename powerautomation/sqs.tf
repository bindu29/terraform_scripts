##################### SQS ##############################

# creation of dead letter queues

resource "aws_sqs_queue" "power_automation" {
  count = length(var.queue_names)
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-raw-datalake-${var.queue_names[count.index]}-dead-queue.fifo"
  fifo_queue = "${var.fifo_queue_status}"
  content_based_deduplication = "${var.content_based_deduplication_status}"
  kms_master_key_id = aws_kms_alias.kpi.id
  kms_data_key_reuse_period_seconds = "${var.kms_data_key_reuse_period_seconds}"
  message_retention_seconds = "${var.message_retention_seconds}"
  visibility_timeout_seconds = "${var.visibility_timeout_seconds}"
  delay_seconds = "${var.delay_seconds}"


  tags = {
    Name = "${var.client}-${var.environment}"
    Environment = "${var.environment}"
    owner = "${var.client}"
    Type = "${var.pipeline}"
  }
}

# creation of queues

resource "aws_sqs_queue" "queue_powerautomation" {
  count = length(var.queue_names)
  name = "kpi-${lower(var.environment)}-${lower(var.client)}-raw-datalake-${var.queue_names[count.index]}.fifo"
  fifo_queue = "${var.fifo_queue_status}"
  content_based_deduplication = "${var.content_based_deduplication_status}"
  kms_master_key_id = aws_kms_alias.kpi.id
  kms_data_key_reuse_period_seconds = "${var.kms_data_key_reuse_period_seconds}"
  message_retention_seconds = "${var.message_retention_seconds}"
  visibility_timeout_seconds = "${var.visibility_timeout_seconds}"
  delay_seconds = "${var.delay_seconds}"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.power_automation[count.index].arn
    maxReceiveCount     = 4
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["${aws_sqs_queue.power_automation[count.index].arn}"]
  })

  tags = {
    Name = "${var.client}-${var.environment}"
    Environment = "${var.environment}"
    owner = "${var.client}"
    Type = "${var.pipeline}"
  }
}