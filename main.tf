# Declare provider resources.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure EC2 instance.
resource "aws_instance" "jenkins_instance" {
  ami                    = "ami-0f34c5ae932e6f0e4"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]
  user_data              = <<-EOF
#!/bin/bash
sudo apt-get update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
EOF
}

#Create a security group resource for Jenkins.
resource "aws_security_group" "jenkins_security_group" {
  name_prefix = "jenkins-sg-"
  vpc_id      = "vpc-0a5ccdf9329529aac"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "jenkins-artifacts-bucket" {
  bucket = "jenkins-artifacts-bdj"
  tags = {
    Name = "Week20_Jenkins_artifacts_bucket"
  }
}