# Infrastructure

## AWS Infrastructure Setup
The code does the following:
1. Creates a new Virtual Private Cloud (VPC)
2. Creates 3 subnets in the new VPC. The script creates 3 public subnets and 3 private subnets, each in a different availability zone in the same region as the VPC
3. Creates an Internet Gateway Links and attaches the Internet Gateway to the VPC
4. Creates a public route table and attaches all public subnets created to the route table
5. Creates a private route table and attaches all private subnets created to the route table
6. Creates a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target
7. Creates an application security group for EC2 with name "application" and ingress rules to allow ingress traffic on port 22, 443, 80 and 8000 globally
8. Creates an EC2 instance in the newly created VPC above with the following specifications:
* Security Group: application
* Instance Type: t2.micro
* Protect against accidental termination: No
* Root Volume Size: 50 GB
* Root Volume Type: General Purpose SSD (GP2)
* User data: Passes S3 bucket name, database name, database host, database username, database password, database port and nodejs port
9. Creates an database security group for RDS with name "database" and ingress rules to allow ingress traffic on port 3306 only from the EC2 instance
10. Creates a private S3 bucket with random name, depending on the environment. Enables SSE-S3 encryption as default and creates a lifecycle policy to transition objects from STANDARD class to STANDARD_IA class after 30 days
11. Creates RDS paramter group named "csye6225" for MySQL 8
12. Creates RDS instance in the newly created VPC above with the following specifications:
* Database Engine: MySQL
* DB Instance Class: db.t3.micro
* Multi-AZ deployment: No
* DB instance identifier: csye6225
* Master username: csye6225
* Master password: Randomly generated password
* Subnet group: Private subnet for RDS instances
* Public accessibility: No
* Database name: csye6225
* Security group: database
13. Creates an IAM policy named "WebAppS3" with appropriate permissions to allow EC2 instance to access the S3 bucket
14. Creates an IAM role named "EC2-CSYE6225" and attaches the IAM policy "WebAppS3" to it. This role will be attached to the instance.
15. Adds an A record to Route53 hosted zone so that the domain points to EC2 public IP address

## Prerequisites
1. Install terraform on your local system
2. Setup an AWS account
3. Install AWS CLI and setup a profile in your local system

## How to create resources?
Run the following commands:
1. terraform init
2. terraform plan (to view the resources that will be deployed)
3. terraform apply

Once "terraform apply" is run, the aforementioned resources would be created using the default variables.

In order to create the above network stack using self-defined variables, you may customize the command mentioned below and run it:

terraform apply -var='profile=demo' 
You can replace profile=demo in the above example with variable_name=value

## How to destroy resources?
Run the following command:
1. terraform destroy

If you have created resources using custom variables, make sure to pass the variables as well with the above command

Note: If you're using custom variables, please ensure that vpccidr, public_subnets_cidr and private_subnets_cidr values are from the same subnet.

## How to create multiple infrastructures using terraform?
You can use terraform workspaces, commands are:
1. terraform workspace new workspace_name - to create a new workspace
2. terraform workspace select workspace_name - to switch to a workspace
3. terraform workspace list - to list the current workspaces and to see which workspace you're currently on