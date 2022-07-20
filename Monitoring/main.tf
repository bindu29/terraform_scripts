
resource "aws_prometheus_workspace" "kpi" {
  alias = "kpi-${var.environment}-${var.pipeline}-${var.service}-sg"

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

data "aws_vpcs" "kpi" {

    tags = {
        Name = "kpi-${var.environment}-${var.client}-VPC"
    }
}
resource "aws_security_group" "kpi" {
  name = "kpi-${var.environment}-${var.pipeline}-${var.service}-sg"
  vpc_id = tolist(data.aws_vpcs.kpi.ids)[0]

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






