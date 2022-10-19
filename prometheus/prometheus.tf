resource "aws_prometheus_workspace" "kpi" {
  alias = "kpi-${var.environment}-${var.pipeline}-${var.service}"

  tags = {
        Name = "${var.client}-${var.environment}"
        Owner = "${var.client}"
        Environment = "${var.environment}"
        Type = "${var.pipeline}"
    }
}
resource "aws_iam_role" "kpi" {
  name = "kpi-${var.client}-kpi-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
  ]
  inline_policy {
    name = "s3_kms_permissions"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:GetObject","kms:Decrypt"]
          Effect   = "Allow"
          Resource = [
            "arn:aws:s3:::kpi-161674638527-terraform-e1/*",
            "arn:aws:kms:us-east-1:*:key/*"
          ]
        },
      ]
    })
  }

  tags =  {
    Name        = "${var.client}-iam-role-prometheus-${var.environment}"
    Owner       = "${var.client}"
    Enviroment  = "${var.environment}"
    Type = "${var.pipeline}"
  }
  
}

resource "aws_iam_instance_profile" "kpi" {
  name = "kpi-${var.client}-instance-profile-${var.environment}"
  role = "${aws_iam_role.kpi.name}"
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
resource "aws_instance" "kpi" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "${var.instancetype}"
  #availability_zone = "${var.ec2_preferred_az}"
  availability_zone = "us-east-1a"
  #vpc_security_group_ids = ["${aws_security_group.kpi_1.id}"]
  subnet_id = tolist(data.aws_subnets.private.ids)[0]
  #key_name = "kpi-${var.environment}-${var.client}-${var.application}-key-1"
  iam_instance_profile = aws_iam_instance_profile.kpi.name
  #root_block_device {
  #  encrypted = "${var.encryption_status}"
  #  kms_key_id = aws_kms_key.kpi.arn
  #}

  tags = {
    Name = "kpi-${lower(var.environment)}-${lower(var.client)}-${lower(var.service)}-instance"
    owner = "${var.client}"
    Environment = "${var.environment}" 
    Type = "${var.pipeline}"
  } 

  #userdata

  user_data = <<EOF
    #! /bin/bash
    sudo -i
    su ec2-user
    cd /home/ec2-user
    echo "Starting UserData script" >> /home/ec2-user/userdata_log
    echo "Downloading Prometheus package" >> /home/ec2-user/userdata_log
    wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
    echo "Promethus package downloaded. Unzip in progress" >> /home/ec2-user/userdata_log
    tar -zxvf prometheus-2.37.0.linux-amd64.tar.gz
    echo "Unzip completed" >> /home/ec2-user/userdata_log
    pwd
    cd prometheus-2.37.0.linux-amd64
    touch targets.json node_targets.json
    echo "Created json files for targets and node_targets" >> /home/ec2-user/userdata_log
    sudo aws s3 cp s3://kpi-161674638527-terraform-e1/monitoring/prometheus/prometheus.yml prometheus.yml
    echo "Downloaded latest prometheus configuration file" >> /home/ec2-user/userdata_log
    sudo sed -i 's+https://aps-workspaces.us-east-1.amazonaws.com/workspaces/ws-03a0bd31-c728-445c-b69e-1658a5eaafae/api/v1/remote_write+${aws_prometheus_workspace.kpi.prometheus_endpoint}api/v1/remote_write+' prometheus.yml
    echo "Updated workspace id in prometheus configuration file" >> /home/ec2-user/userdata_log
    sudo aws s3 cp s3://kpi-161674638527-terraform-e1/monitoring/prometheus/prometheus_service_info.txt /etc/systemd/system/prometheus-server.service
    echo "Downloaded prometheus service configuration file" >> /home/ec2-user/userdata_log
    sudo systemctl start prometheus-server
    echo "Started prometheus-server service" >> /home/ec2-user/userdata_log
    echo "Status:" >> /home/ec2-user/userdata_log
    sudo systemctl status prometheus-server >> /home/ec2-user/userdata_log
    sudo systemctl enable prometheus-server
    echo "Configured prometheus-server service to run at server boot up" >> /home/ec2-user/userdata_log
    EOF
}
