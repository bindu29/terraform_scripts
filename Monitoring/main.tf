
resource "aws_prometheus_workspace" "kpi" {
  alias = "kpi-${var.environment}-${var.pipeline}-${var.service}"

  tags = {
        Name = "${var.client}-${var.environment}"
        Owner = "${var.client}"
        Environment = "${var.environment}"
        Type = "${var.pipeline}"
    }
}
resource "aws_iam_role" "ec2-prometheus-role" {
  name = "kpi-${var.client}-ec2-prometheus-role-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags =  {
    Name        = "${var.client}-iam-role-prometheus-${var.environment}"
    Owner       = "${var.client}"
    Enviroment  = "${var.environment}"
  }
  
}

resource "aws_iam_role_policy_attachment" "ec2-readonly-role-policy-attach" {
  role       = "${aws_iam_role.ec2-prometheus-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "kpi-${var.client}-instance-profile-${var.environment}"
  role = "${aws_iam_role.ec2-prometheus-role.name}"
}


resource "aws_security_group" "kpi" {
  name = "kpi-${var.environment}-${var.pipeline}-${var.service}-sg"


  tags = {
        Name = "${var.client}-${var.environment}"
        Owner = "${var.client}"
        Environment = "${var.environment}"
        Type = "${var.pipeline}"
    }
}
resource "aws_security_group_rule" "kpi" {

  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.kpi.id
  self = true
  depends_on=[aws_security_group.kpi]
}
resource "aws_grafana_workspace" "kpi" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.assume.arn
}

resource "aws_iam_role" "assume" {
  name = "grafana-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}
