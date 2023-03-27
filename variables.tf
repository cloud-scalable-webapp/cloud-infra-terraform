variable "profile" {
  type        = string
  default     = "demo"
  description = "Account in which the resources will be deployed"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region where the resources will be deployed"
}

variable "vpc_name" {
  type        = string
  default     = "csye6225"
  description = "Name of the VPC"
}

variable "vpccidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
  validation {
    condition     = contains(["10.0.0.0/16", "192.168.0.0/16", "172.31.0.0/16"], var.vpccidr)
    error_message = "Please enter a valid CIDR. Allowed values are 10.0.0.0/16, 192.168.0.0/16 and 172.31.0.0/16"
  }
}

variable "public_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Public subnets for VPC"
}

variable "private_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "Private subnets for VPC"
}

variable "ami_id" {
  type        = string
  description = "AWS AMI ID"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 Instance Type"
}

variable "ec2_instance_name" {
  type        = string
  default     = "csye6225"
  description = "EC2 Instance Name"
}

variable "ebs_volume_size" {
  type        = string
  default     = 50
  description = "EBS Volume Size"
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS Volume Type"
}

variable "application_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))

  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "SSH"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "HTTPS"
    },
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "HTTPS"
    },
  ]
}

variable "application_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))

  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      description = "Allow Outbound Traffic"
    },
  ]
}

variable "delete_on_termination" {
  type    = string
  default = true
}

variable "associate_public_ip_address" {
  type    = string
  default = true
}

variable "number_of_instances" {
  type    = number
  default = 1
}

variable "number_of_db_instances" {
  type    = number
  default = 1
}

variable "aws_security_group_name" {
  type    = string
  default = "application"
}

variable "aws_security_group_name_database" {
  type    = string
  default = "database"
}

variable "database_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))

  default = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL"
    },
  ]
}

variable "aws_db_parameter_group_name" {
  type    = string
  default = "csye6225"
}

variable "aws_db_parameter_family" {
  type    = string
  default = "mysql8.0"
}

variable "aws_db_parameter_description" {
  type    = string
  default = "Parameter Group for CSYE 6225"
}

variable "aws_db_engine" {
  type    = string
  default = "mysql"
}

variable "aws_db_engine_version" {
  type    = string
  default = "8.0"
}

variable "aws_db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "aws_db_multi_az" {
  type    = bool
  default = "false"
}

variable "aws_db_username" {
  type    = string
  default = "csye6225"
}

variable "aws_db_password" {
  type    = string
  default = "dbTz2TtYQHQ5QSMIgrngzw"
}

variable "aws_db_name" {
  type    = string
  default = "csye6225"
}

variable "aws_db_publicly_accessible" {
  type    = bool
  default = "false"
}

variable "aws_db_subnet_group_name" {
  type    = string
  default = "csye6225"
}

variable "aws_db_instance_name" {
  type    = string
  default = "CSYE 6225 DB"
}

variable "aws_db_identifier" {
  type    = string
  default = "csye6225"
}

variable "db_allocated_storage" {
  type    = number
  default = 10
}

variable "max_db_allocated_storage" {
  type    = number
  default = 50
}

variable "node_port" {
  type    = number
  default = 8000
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "bucket_access" {
  type    = string
  default = "private"
}

variable "object_force_remove" {
  type    = bool
  default = "true"
}

variable "s3_encryption" {
  type    = string
  default = "AES256"
}

variable "s3_transition_days" {
  type    = number
  default = 30
}

variable "s3_transition_class" {
  type    = string
  default = "STANDARD_IA"
}

variable "bucket_string_length" {
  type    = string
  default = 10
}

variable "database_string_length" {
  type    = string
  default = 16
}

variable "true" {
  type    = bool
  default = "true"
}

variable "false" {
  type    = bool
  default = "false"
}

variable "s3_transition_id" {
  type    = string
  default = "transition_objects"
}

variable "s3_lifecycle_config_enabled" {
  type    = string
  default = "Enabled"
}

variable "s3_iam_policy_name" {
  type    = string
  default = "WebAppS3"
}

variable "aws_iam_role_name" {
  type    = string
  default = "EC2-CSYE6225"
}

variable "zone_id" {
  type    = string
  default = "Z0124630195MF665Z5J68"
}

variable "record_name" {
  type    = string
  default = "demo.clokesh.me"
}

variable "record_ttl" {
  type    = number
  default = 5
}

variable "record_type" {
  type    = string
  default = "A"
}

variable "cloudwatch_agent_server_policy" {
  type    = string
  default = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

variable "log_group_name" {
  type    = string
  default = "csye6225"
}

variable "log_stream_name" {
  type    = string
  default = "webapp"
}