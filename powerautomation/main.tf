# Get data of VPC
data "aws_vpcs" "kpi"{

  tags ={
    Name = "kpi-test-vpc"
  }
}

# Get private subnet Ids
data "aws_subnets" "private"{
    filter {
      name="vpc-id"
      values=[data.aws_vpcs.kpi.ids[0]]
    }
    tags = {
      Name = "*private*"
    }
}    

# Get public subnet Ids
data "aws_subnets" "public"{
    filter {
      name="vpc-id"
      values=[data.aws_vpcs.kpi.ids[0]]
    }
    tags = {
      Name = "*public*"
    }
}
