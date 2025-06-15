terraform {
  backend "local" {
    # relative path from deployments/aws to infra-state repo's terraform.tfstate file
    path = "../../../infra-state/terraform/terraform.tfstate"
  }
}
