output "profile" {
  value = var.profile
}

output "region" {
  value = var.region
}

output "vpc_name" {
  value = var.vpc_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = zipmap(aws_subnet.public_subnets[*].cidr_block, aws_subnet.public_subnets[*].availability_zone)
}

output "private_subnets" {
  value = zipmap(aws_subnet.private_subnets[*].cidr_block, aws_subnet.private_subnets[*].availability_zone)
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gateway.id
}

output "public_subnets_route_table" {
  value = aws_route_table.public_subnets_route_table.id
}

output "private_subnets_route_table" {
  value = aws_route_table.private_subnets_route_table.id
}

output "ec2_instance_name" {
  value = var.ec2_instance_name
}

output "ec2_public_ip" {
  value = zipmap(aws_instance.application[*].id, aws_instance.application[*].public_ip)
}

output "ec2_ami_id" {
  value = var.ami_id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.csyebucket.bucket
}

output "rds_instance_id" {
  value = aws_db_instance.mysql.id
}