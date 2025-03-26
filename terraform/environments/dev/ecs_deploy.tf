module "ecr" {
  source              = "../../modules/ecr"
  ecr_repository_name = var.ecr_repository_name
  environment         = var.environment
  region              = var.region
}

module "ecs" {
  source              = "../../modules/ecs"
  image               = var.image
  ecr_repository_name = var.ecr_repository_name
  environment         = var.environment
  region              = var.region
}
