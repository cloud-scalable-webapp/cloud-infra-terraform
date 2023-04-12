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
  description = "Allow EC2 inbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name" = "application"
  }
}

resource "aws_security_group_rule" "webapp_ingress" {
  type                     = "ingress"
  count                    = length(var.webapp_ingress_rules)
  from_port                = var.webapp_ingress_rules[count.index].from_port
  to_port                  = var.webapp_ingress_rules[count.index].to_port
  protocol                 = var.webapp_ingress_rules[count.index].protocol
  source_security_group_id = aws_security_group.load_balancer.id
  description              = var.webapp_ingress_rules[count.index].description
  security_group_id        = aws_security_group.application.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  count             = length(var.ssh_ingress_rules)
  from_port         = var.ssh_ingress_rules[count.index].from_port
  to_port           = var.ssh_ingress_rules[count.index].to_port
  protocol          = var.ssh_ingress_rules[count.index].protocol
  cidr_blocks       = [var.ssh_ingress_rules[count.index].cidr_blocks]
  description       = var.ssh_ingress_rules[count.index].description
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  count             = length(var.application_egress_rules)
  from_port         = var.application_egress_rules[count.index].from_port
  to_port           = var.application_egress_rules[count.index].to_port
  protocol          = var.application_egress_rules[count.index].protocol
  cidr_blocks       = [var.application_egress_rules[count.index].cidr_block]
  description       = var.application_egress_rules[count.index].description
  security_group_id = aws_security_group.application.id
}

# resource "aws_instance" "application" {
#   ami                         = var.ami_id
#   instance_type               = var.ec2_instance_type
#   associate_public_ip_address = var.associate_public_ip_address
#   vpc_security_group_ids      = [aws_security_group.application.id]
#   subnet_id                   = aws_subnet.public_subnets[0].id
#   iam_instance_profile        = aws_iam_instance_profile.ec2-instance-profile.name
#   root_block_device {
#     delete_on_termination = var.delete_on_termination
#     volume_size           = var.ebs_volume_size
#     volume_type           = var.ebs_volume_type
#   }
#   user_data = <<EOF
# 		#! /bin/bash
#   echo DB_HOST=${aws_db_instance.mysql.address} >> /etc/environment
#   echo DB_USER=${var.aws_db_username} >> /etc/environment
#   echo DB_PASSWORD=${random_string.database_password.id} >> /etc/environment
#   echo DB_NAME=${var.aws_db_name} >> /etc/environment
#   echo NODE_PORT=${var.node_port} >> /etc/environment
#   echo DB_PORT=${var.db_port} >> /etc/environment
#   echo S3_BUCKET_NAME=${aws_s3_bucket.csyebucket.bucket} >> /etc/environment
#   sudo systemctl daemon-reload
#   sudo systemctl restart webapp
# 	EOF
#   tags = {
#     Name = var.ec2_instance_name
#   }
# }

resource "aws_security_group" "database" {
  name        = var.aws_security_group_name_database
  description = "Allow inbound DB traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name" = "database"
  }
}

resource "aws_security_group_rule" "database_ingress" {
  type                     = "ingress"
  count                    = length(var.database_ingress_rules)
  from_port                = var.database_ingress_rules[count.index].from_port
  to_port                  = var.database_ingress_rules[count.index].to_port
  protocol                 = var.database_ingress_rules[count.index].protocol
  source_security_group_id = aws_security_group.application.id
  description              = var.database_ingress_rules[count.index].description
  security_group_id        = aws_security_group.database.id
}

resource "aws_db_parameter_group" "csye6225" {
  name        = var.aws_db_parameter_group_name
  family      = var.aws_db_parameter_family
  description = var.aws_db_parameter_description
}

resource "aws_db_subnet_group" "csye6225" {
  name       = var.aws_db_subnet_group_name
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_kms_key" "rds" {
  description             = "RDS KMS CMK"
  deletion_window_in_days = 30
}

resource "aws_db_instance" "mysql" {
  engine                 = var.aws_db_engine
  engine_version         = var.aws_db_engine_version
  instance_class         = var.aws_db_instance_class
  identifier             = var.aws_db_identifier
  multi_az               = var.aws_db_multi_az
  username               = var.aws_db_username
  password               = random_string.database_password.id
  parameter_group_name   = aws_db_parameter_group.csye6225.name
  db_name                = var.aws_db_name
  db_subnet_group_name   = aws_db_subnet_group.csye6225.name
  publicly_accessible    = var.aws_db_publicly_accessible
  vpc_security_group_ids = [aws_security_group.database.id]
  allocated_storage      = var.db_allocated_storage
  max_allocated_storage  = var.max_db_allocated_storage
  skip_final_snapshot    = var.true
  storage_encrypted      = var.true
  kms_key_id             = aws_kms_key.rds.arn

  tags = {
    Name = var.aws_db_instance_name
  }
}

resource "random_string" "bucket_string" {
  length  = var.bucket_string_length
  special = var.false
  upper   = var.false
}

resource "random_string" "database_password" {
  length  = var.database_string_length
  special = var.false
}

resource "aws_s3_bucket" "csyebucket" {
  bucket        = "${var.profile}-csye-${random_string.bucket_string.id}"
  force_destroy = var.object_force_remove

  tags = {
    Name        = "${var.profile} Bucket"
    Environment = var.profile
  }
}

resource "aws_s3_bucket_acl" "csye_bucket_acl" {
  bucket = aws_s3_bucket.csyebucket.id
  acl    = var.bucket_access
}

resource "aws_s3_bucket_server_side_encryption_configuration" "csye_bucket_encryption" {
  bucket = aws_s3_bucket.csyebucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_encryption
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "csye_bucket_lifecycle_config" {
  bucket = aws_s3_bucket.csyebucket.id
  rule {
    id     = var.s3_transition_id
    status = var.s3_lifecycle_config_enabled
    transition {
      days          = var.s3_transition_days
      storage_class = var.s3_transition_class
    }
  }
}

resource "aws_s3_bucket_public_access_block" "csyebucket" {
  bucket = aws_s3_bucket.csyebucket.id

  block_public_acls       = var.true
  block_public_policy     = var.true
  ignore_public_acls      = var.true
  restrict_public_buckets = var.true
}

data "aws_iam_policy_document" "WebAppS3" {
  statement {
    sid = "1"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.csyebucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.csyebucket.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "WebAppS3" {
  name   = var.s3_iam_policy_name
  path   = "/"
  policy = data.aws_iam_policy_document.WebAppS3.json
}

resource "aws_iam_role" "EC2-CSYE6225" {
  name = var.aws_iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EC2-CSYE6225" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = aws_iam_policy.WebAppS3.arn
}

data "aws_iam_policy" "CloudWatch" {
  arn = var.cloudwatch_agent_server_policy
}

resource "aws_iam_role_policy_attachment" "EC2-CSYE6225_CW" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = data.aws_iam_policy.CloudWatch.arn
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = var.ec2_instance_name
  role = aws_iam_role.EC2-CSYE6225.name
}

resource "aws_route53_record" "application" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type
  alias {
    name                   = aws_lb.csye.dns_name
    zone_id                = aws_lb.csye.zone_id
    evaluate_target_health = var.true
  }
}

resource "aws_cloudwatch_log_group" "csye6225" {
  name = var.log_group_name
}

resource "aws_cloudwatch_log_stream" "webapp" {
  name           = var.log_stream_name
  log_group_name = aws_cloudwatch_log_group.csye6225.name
}

resource "aws_security_group" "load_balancer" {
  name        = var.aws_security_group_name_load_balancer
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name" = "load balancer security group"
  }
}

resource "aws_security_group_rule" "load_balancer_ingress" {
  type              = "ingress"
  count             = length(var.load_balancer_ingress_rules)
  from_port         = var.load_balancer_ingress_rules[count.index].from_port
  to_port           = var.load_balancer_ingress_rules[count.index].to_port
  protocol          = var.load_balancer_ingress_rules[count.index].protocol
  cidr_blocks       = [var.load_balancer_ingress_rules[count.index].cidr_block]
  description       = var.load_balancer_ingress_rules[count.index].description
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "load_balancer_egress" {
  type              = "egress"
  count             = length(var.application_egress_rules)
  from_port         = var.application_egress_rules[count.index].from_port
  to_port           = var.application_egress_rules[count.index].to_port
  protocol          = var.application_egress_rules[count.index].protocol
  cidr_blocks       = [var.application_egress_rules[count.index].cidr_block]
  description       = var.application_egress_rules[count.index].description
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_lb_target_group" "csye" {
  name     = var.lb_tg_name
  port     = var.lb_tg_port
  protocol = var.lb_tg_protocol
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled           = var.true
    healthy_threshold = var.lg_tg_health_threshold
    interval          = var.lg_tg_health_interval
    path              = "/check"
    port              = var.lb_tg_port
    timeout           = var.lg_tg_health_timeout
  }
}

# resource "aws_lb_target_group_attachment" "csye" {
#   target_group_arn = aws_lb_target_group.csye.arn
#   target_id        = aws_instance.application.id
#   port             = var.lb_tg_port
# }

resource "aws_lb" "csye" {
  name               = var.lb_name
  internal           = var.false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public_subnets[*].id
}

resource "aws_lb_listener" "csye" {
  load_balancer_arn = aws_lb.csye.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.csye.arn
  }
}

locals {
  user_data_script = <<EOF
	#! /bin/bash
  echo DB_HOST=${aws_db_instance.mysql.address} >> /etc/environment
  echo DB_USER=${var.aws_db_username} >> /etc/environment
  echo DB_PASSWORD=${random_string.database_password.id} >> /etc/environment
  echo DB_NAME=${var.aws_db_name} >> /etc/environment
  echo NODE_PORT=${var.node_port} >> /etc/environment
  echo DB_PORT=${var.db_port} >> /etc/environment
  echo S3_BUCKET_NAME=${aws_s3_bucket.csyebucket.bucket} >> /etc/environment
  sudo systemctl daemon-reload
  sudo systemctl restart webapp
  EOF
}

resource "aws_kms_key" "ebs" {
  description             = "EBS KMS CMK"
  deletion_window_in_days = 30
}

resource "aws_kms_key_policy" "ebs" {
  key_id = aws_kms_key.ebs.id
  policy = jsonencode({
    Id = "ebs-key"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::209538387374:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::209538387374:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        }

        Resource = "*"
        Sid      = "Allow use of the key"
      },
      {
        Sid    = "Allow attachment of persistent resources",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::209538387374:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
          ]
        },
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_launch_template" "asg_launch_config" {
  name          = var.asg_launch_config_name
  image_id      = var.ami_id
  instance_type = var.ec2_instance_type
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [aws_security_group.application.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-instance-profile.name
  }
  block_device_mappings {
    device_name = var.device_name

    ebs {
      delete_on_termination = var.delete_on_termination
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      encrypted             = var.true
      kms_key_id            = aws_kms_key.ebs.arn
    }
  }
  key_name  = var.name
  user_data = base64encode(local.user_data_script)
  tags = {
    Name = var.asg_launch_config_name
  }
}

resource "aws_autoscaling_group" "csye" {
  desired_capacity    = var.mindes_size
  max_size            = var.max_size
  min_size            = var.mindes_size
  default_cooldown    = var.cooldown_period
  vpc_zone_identifier = aws_subnet.public_subnets[*].id
  launch_template {
    id      = aws_launch_template.asg_launch_config.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.csye.arn]
  tag {
    key                 = var.asg_app
    value               = var.asg_webapp
    propagate_at_launch = var.true
  }
  tag {
    key                 = var.asg_name
    value               = var.profile
    propagate_at_launch = var.true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.csye.id
  lb_target_group_arn    = aws_lb_target_group.csye.arn
}

resource "aws_autoscaling_policy" "high_cpu" {
  name                   = "HighCPU"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.csye.name
  cooldown               = var.cooldown_period
  scaling_adjustment     = var.one
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "High CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.csye.name
  }

  alarm_description = "This metric monitors EC2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.high_cpu.arn]
}

resource "aws_autoscaling_policy" "low_cpu" {
  name                   = "LowCPU"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.csye.name
  cooldown               = var.cooldown_period
  scaling_adjustment     = var.minusone
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "Low CPU"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.csye.name
  }

  alarm_description = "This metric monitors EC2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.low_cpu.arn]
}