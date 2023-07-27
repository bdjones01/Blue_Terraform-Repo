terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "MyBlueweb" {
  ami           = "ami-05548f9cecf47b442"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}