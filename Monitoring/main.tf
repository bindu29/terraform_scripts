
resource "aws_prometheus_workspace" "kpi" {
  alias = "kpi-${var.environment}-${var.pipeline}-${var.service}-sg"

  tags = {
        Name = "${var.client}-${var.environment}"
        Owner = "${var.client}"
        Environment = "${var.environment}"
        Type = "${var.pipeline}"
    }
}

