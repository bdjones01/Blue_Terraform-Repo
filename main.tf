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
  ami                    = "ami-0df6ef5f152160524"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]
  user_data              = <<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install openjdk-11-jre -y
sudo curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
sudo echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] 
https://pkg.jenkins.io/debian binary | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install fontconfig openjdk-11-jre -y
sudo apt-get install jenkins -y
systemctl enable jenkins 
systemctl start jenkins
EOF
}

#Create a security group resource for Jenkins.
resource "aws_security_group" "jenkins_security_group" {
  name_prefix = "jenkins-sg-"
  vpc_id      = "vpc-0f531f3941e031963"

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
#Configure s3 bucket for Jenkins' artifacts
resource "aws_s3_bucket" "jenkins-artifacts-bucket" {
  bucket = "jenkins-artifacts-bdj"
  tags = {
    Name = "Week20_Jenkins_artifacts_bucket"
  }
}
