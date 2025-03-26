module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "5.12.0"
  cluster_name = "quickecs-${var.environment}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    gentle-api = {
      cpu    = 256
      memory = 512

      # Container definition(s)
      container_definitions = {
        gentle-api = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = var.image
          port_mappings = [
            {
              name          = "quickecs-${var.environment}"
              containerPort = 8000
              hostPort      = 8000
              protocol      = "tcp"
            }
          ]

          enable_cloudwatch_logging = true
          #log_configuration = {
          #  logDriver = "awslogs"
          #}
          memory_reservation = 100
        }
      }

      #service_connect_configuration = {
      #  namespace = "gentle-api"
      #  service = {
      #    client_alias = {
      #      port     = 80
      #      dns_name = "quickecs-${var.environment}"
      #    }
      #    port_name      = "http"
      #    discovery_name = "quickecs-${var.environment}"
      #  }
      #}

      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        alb_ingress_80 = {
          type        = "ingress"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }
        alb_ingress_8000 = {
          type        = "ingress"
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          description = "Container port"
          cidr_blocks = [module.vpc.vpc_cidr_block]
        }
        alb_ingress_443 = {
          type        = "ingress"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          description = "Https port"
          cidr_blocks = ["0.0.0.0/0"]
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }

  depends_on = [module.vpc]
}
