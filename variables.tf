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
  type    = string
  default = "csye6225"
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

variable "webapp_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))

  default = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "Webapp"
    }
  ]
}

variable "ssh_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))

  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "SSH"
    }
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

variable "record_type" {
  type    = string
  default = "A"
}

variable "cloudwatch_agent_server_policy" {
  type    = string
  default = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# variable "asg_policy_arn" {
#   type    = string
#   default = "arn:aws:iam::aws:policy/aws-service-role/AutoScalingServiceRolePolicy"
# }

# variable "rds_policy_arn" {
#   type    = string
#   default = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSServiceRolePolicy"
# }

variable "log_group_name" {
  type    = string
  default = "csye6225"
}

variable "log_stream_name" {
  type    = string
  default = "webapp"
}

variable "aws_security_group_name_load_balancer" {
  type    = string
  default = "load balancer"
}

variable "load_balancer_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))

  default = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "HTTPS"
    }
  ]
}

variable "lb_tg_protocol" {
  type    = string
  default = "HTTP"
}

variable "lb_tg_name" {
  type    = string
  default = "csye6225-lb-tg"
}

variable "lb_tg_port" {
  type    = number
  default = 8000
}

variable "lg_tg_health_threshold" {
  type    = number
  default = 2
}

variable "lg_tg_health_interval" {
  type    = number
  default = 60
}

variable "lg_tg_health_timeout" {
  type    = number
  default = 30
}

variable "lb_name" {
  type    = string
  default = "csye6225"
}

variable "lb_type" {
  type    = string
  default = "application"
}

variable "lb_listener_port" {
  type    = number
  default = 443
}

variable "lb_listener_protocol" {
  type    = string
  default = "HTTPS"
}

variable "asg_launch_config_name" {
  type    = string
  default = "asg_launch_config"
}

variable "device_name" {
  type    = string
  default = "/dev/xvda"
}

variable "max_size" {
  type    = number
  default = 3
}

variable "mindes_size" {
  type    = number
  default = 1
}

variable "cooldown_period" {
  type    = number
  default = 60
}

variable "asg_app" {
  type    = string
  default = "Application"
}

variable "asg_webapp" {
  type    = string
  default = "Webapp"
}

variable "asg_name" {
  type    = string
  default = "Name"
}

variable "name" {
  type    = string
  default = "csye"
}

variable "one" {
  type    = number
  default = 1
}

variable "minusone" {
  type    = number
  default = -1
}

variable "kms_key_id_ebs" {
  type    = string
  default = "arn:aws:kms:us-east-1:209538387374:key/fecd44a2-45cb-49b0-90ea-63a94780f052"
}

variable "kms_key_id_rds" {
  type    = string
  default = "arn:aws:kms:us-east-1:209538387374:key/741556ff-fd59-4f05-be21-4af634524bc1"
}

variable "certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:209538387374:certificate/cf6f0f2f-935c-4763-9aa2-8924134c2510"
}