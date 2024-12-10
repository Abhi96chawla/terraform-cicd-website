# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Store the Terraform state file in an S3 bucket
terraform {
  backend "s3" {
    bucket = "terraform-state-bucketabhi-6222"
    key    = "build/terraform.tfstate"
    region = "us-east-1"
  }
}

# Create the S3 bucket for the Terraform state
# resource "aws_s3_bucket" "terraform_state_bucket" {
#   bucket = "terraform-state-bucketabhi-6222"
#   acl    = "private"

#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name = "Terraform State Bucket"
#     Environment = "Dev"
#   }
# }

# Create the default VPC if it doesn't exist
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
}

# Use a data source to get all available availability zones
data "aws_availability_zones" "available_zones" {}

# Create a default subnet if it doesn't exist
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "Default Subnet"
  }
}

# Create a security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 Security Group"
  }
}

# Use a data source to get a registered Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Launch an EC2 instance and install the website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "new"  # Replace with your key pair name
  user_data              = file("install_techmax.sh")

  tags = {
    Name = "Website"
  }
}

# Output the URL of the EC2 instance
output "ec2_public_ipv4_url" {
  value = join("", ["http://", aws_instance.ec2_instance.public_ip])
}
