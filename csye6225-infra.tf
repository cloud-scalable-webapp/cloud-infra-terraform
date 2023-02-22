resource "aws_vpc" "main" {
  cidr_block = var.vpccidr

  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "az" {}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets_cidr)
  cidr_block        = element(var.public_subnets_cidr, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.az.names[count.index]

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets_cidr)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.az.names[count.index]

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway for VPC ${var.vpc_name}"
  }
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "Public subnet route table"
  }
}

resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private subnet route table for VPC "
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route_table_association" "private_subnets" {
  route_table_id = aws_route_table.private_subnets_route_table.id
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}

resource "aws_security_group" "application" {
  name        = var.aws_security_group_name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  count             = length(var.application_ingress_rules)
  from_port         = var.application_ingress_rules[count.index].from_port
  to_port           = var.application_ingress_rules[count.index].to_port
  protocol          = var.application_ingress_rules[count.index].protocol
  cidr_blocks       = [var.application_ingress_rules[count.index].cidr_block]
  description       = var.application_ingress_rules[count.index].description
  security_group_id = aws_security_group.application.id
}

resource "aws_instance" "application" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.application.id]
  count                       = var.number_of_instances
  subnet_id                   = element(aws_subnet.public_subnets[*].id, count.index)
  root_block_device {
    delete_on_termination = var.delete_on_termination
    volume_size           = var.ebs_volume_size
    volume_type           = var.ebs_volume_type
  }

  tags = {
    Name = var.ec2_instance_name
  }
}