terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket         = "quickecs-tf-state-dev"
    key            = "ecr/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "quickecs-terraform-state-dev"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}


provider "aws" {
  region = "us-west-1"
}