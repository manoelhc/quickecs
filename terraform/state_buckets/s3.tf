provider "aws" {
  region = var.region
}

# Create the S3 bucket for the Terraform state files
resource "aws_s3_bucket" "terraform_state" {
  bucket = "quickecs-tf-state-${var.environment}"
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
  lifecycle {
    # prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "terraform_state" {
  description             = "Quickecs Terraform state buckets KMS key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_policy     = true
  block_public_acls       = true
}

resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.terraform_state.id
  target_prefix = "logs/"
}


output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}