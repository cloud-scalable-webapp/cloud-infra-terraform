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