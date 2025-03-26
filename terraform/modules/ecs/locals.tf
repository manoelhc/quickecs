data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  alb_name   = "quickecs-${var.environment}"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  name = "${local.alb_name}-${local.account_id}"
}
