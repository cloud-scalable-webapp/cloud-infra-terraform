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