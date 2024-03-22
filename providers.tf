terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1.14"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.83.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0.0"
    }
  }
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "aws" {
  region = var.aws_region
}

provider "boundary" {
  addr                   = trimspace(module.hcp.boundary_cluster_url)
  auth_method_login_name = var.hcp_boundary_admin
  auth_method_password   = var.hcp_boundary_password
}

provider "vault" {
  address                  = module.hcp.vault_public_endpoint_url
  token                    = module.hcp.vault_admin_token
  set_namespace_from_token = true
}
