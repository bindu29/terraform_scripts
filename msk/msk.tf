resource "aws_msk_configuration" "kpi" {

    name="kpi-${var.environment}-${var.client}-${var.service}-configuration"
    kafka_versions = ["${var.kafka_versions}"]
    server_properties = "${var.server_properties}"
  
}

# Get data of VPC
data "aws_vpcs" "kpi"{

  tags ={
    Name = "kpi"
  }
}

# Get subnet Ids
data "aws_subnets" "kpi"{

  filter {
    name = "vpc-id"
    values = data.aws_vpcs.kpi.ids
  }
  # filter {
  #   name = "tag:deployment"
  #   values = "private"
  # }
}

# Create security group resource
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

data "aws_kms_alias" "kpi"{

  name = "alias/${var.client}-${var.environment}"
}

resource "aws_msk_cluster" "kpi" {

    cluster_name = "kpi-${var.environment}-${var.pipeline}-${var.service}"
    kafka_version = "${var.kafka_versions}"
    
    number_of_broker_nodes = "${var.broker_count}"
  
    broker_node_group_info {
      
      instance_type = "${var.instance_type}"
      ebs_volume_size = "${var.ebs_volume_size}"
      client_subnets = [tolist(data.aws_subnets.kpi.ids)[0],tolist(data.aws_subnets.kpi.ids)[1]]
      security_groups = [aws_security_group.kpi.id]
    }

    encryption_info {
      
      encryption_at_rest_kms_key_arn = data.aws_kms_alias.kpi.arn
      encryption_in_transit {
          client_broker = "${var.encryption_type}"
          in_cluster = true
      }
    }

    open_monitoring {
      prometheus {
        jmx_exporter {
          enabled_in_broker = true
        }
        node_exporter {
          enabled_in_broker = true
        }
      }
    }

    tags = {
        Name = "${var.client}-${var.environment}"
        Owner = "${var.client}"
        Environment = "${var.environment}"
        Type = "${var.pipeline}"
    }
    depends_on=[aws_security_group_rule.kpi]
}
