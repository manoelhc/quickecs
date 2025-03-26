variable "environment" {
  description = "The environment in which the resources are being created"
  type        = string
}

variable "region" {
  description = "The AWS region in which the resources are being created"
  type        = string
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  type        = string
}