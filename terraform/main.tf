terraform {
  required_version = "~> 0.12"

  backend "s3" {
    key     = "terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

module "infrastructure" {
  source    = "./modules/infrastructure"
  project   = var.project
  vpc_cidr  = "10.0.0.0/16"
  az_count  = 2
  app_count = 2
  app_port  = 80
  db_name   = "project_base"
  db_user   = "project_user"
  db_pass   = var.db_pass
  tag       = var.tag
}
