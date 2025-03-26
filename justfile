set dotenv-load


bucket_name := shell("cat terraform/state_buckets/terraform.tfstate | jq -r '.outputs.bucket_name.value'")

# Build docker image
build:
  docker build -t ${IMAGE_NAME} -f gentle_api/Dockerfile .
  docker tag ${IMAGE_NAME} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest

# Push docker image to ECR
push:
  aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
  docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest

_build-state-buckets:
  #/bin/sh
  cd terraform/state_buckets; \
    terraform init -var-file ../../tfvars/dev.tfvars; \
    terraform apply -lock=false -var-file ../tfvars/dev.tfvars -auto-approve; \
  cd -


_build-ecr:
  #/bin/sh
  cd terraform/environments/dev; \
    terraform init -var-file ../../tfvars/dev.tfvars; \
    terraform apply -lock=false -target module.ecr -var-file ../../tfvars/dev.tfvars -auto-approve; \
  cd -

# Build and push docker image to ECR
deploy-image: _build-state-buckets _build-ecr build push

_build-ecs:
  #/bin/sh
  cd terraform/environments/dev; \
    terraform init -var-file ../../tfvars/dev.tfvars; \
    terraform apply -lock=false -var-file ../../tfvars/dev.tfvars -target module.alb -auto-approve -var image="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest"; \
    terraform apply -lock=false -var-file ../../tfvars/dev.tfvars -auto-approve -var image="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest"; \
  cd -

# Create the ECS cluster and service with the new image
deploy-ecs: _build-ecs

# Deploy the application, from building the image to deploying the ECS service
deploy-all: deploy-image deploy-ecs

# This recipe
help:
  @just -l

# Destroy all resources
destroy-all:
  #/bin/bash
  cd terraform/environments/dev; \
    terraform init -var-file ../../tfvars/dev.tfvars; \
    terraform destroy -lock=false -var-file ../../tfvars/dev.tfvars -auto-approve; \
  cd -

  if [ -n "{{bucket_name}}" ] && [ "{{bucket_name}}" != null ]; then \
    echo "Emptying bucket: {{bucket_name}}" ; \
    list_of_objects=$(aws s3api list-object-versions --bucket "{{bucket_name}}" --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}'); \
    if [ -n "$list_of_objects" ]; then \
      aws s3api delete-objects --bucket "{{bucket_name}}" --delete "$list_of_objects"; \
      aws s3 rm s3://{{bucket_name}} --recursive; \
    fi; \
  fi

  cd terraform/state_buckets; \
    terraform init -var-file ../../tfvars/dev.tfvars; \
    terraform destroy -lock=false -var-file ../tfvars/dev.tfvars -auto-approve; \
  cd -

just-doc:
  terraform-docs terraform/environments markdown table


fmt:
  terraform fmt -recursive

tfsec:
  tfsec terraform/environments