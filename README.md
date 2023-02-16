# Infrastructure

## AWS Networking Setup
The code does the following:
1. Creates a new Virtual Private Cloud (VPC)
2. Creates 3 subnets in the new VPC. The script creates 3 public subnets and 3 private subnets, each in a different availability zone in the same region as the VPC
3. Creates an Internet Gateway Links and attaches the Internet Gateway to the VPC
4. Creates a public route table and attaches all public subnets created to the route table
5. Creates a private route table and attaches all private subnets created to the route table
6. Creates a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target

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

terraform apply -var='profile=demo' -var='region=us-east-1' -var='vpc_name=csye' -var='vpccidr=10.0.0.0/16' -var='public_subnets_cidr=["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]' -var='private_subnets_cidr=["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]'

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