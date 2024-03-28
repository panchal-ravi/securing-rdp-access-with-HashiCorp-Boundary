locals {
  boundary_cluster_id = lower("boundary-${random_string.suffix.result}")
  vault_cluster_id    = lower("vault-${random_string.suffix.result}")
  deployment_id       = lower("hashi-demo-${random_string.suffix.result}")
  hvn_id              = lower("hvn-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

module "hcp" {
  source                  = "./modules/hcp"
  hcp_boundary_cluster_id = local.boundary_cluster_id
  hcp_vault_cluster_id    = local.vault_cluster_id
  hvn_id                  = local.hvn_id
  hcp_boundary_admin      = var.hcp_boundary_admin
  hcp_boundary_password   = var.hcp_boundary_password
  hcp_boundary_tier       = var.hcp_boundary_tier
  hcp_vault_tier          = var.hcp_vault_tier
  region                  = var.aws_region
}

module "resources" {
  source              = "./modules/resources"
  instance_type       = var.aws_instance_type
  deployment_id       = local.deployment_id
  vpc_cidr            = var.aws_vpc_cidr
  public_subnets      = var.aws_public_subnets
  private_subnets     = var.aws_private_subnets
  boundary_cluster_id = module.hcp.boundary_cluster_id
  vault_cluster_url   = module.hcp.vault_private_endpoint_url
  boundary_version    = var.boundary_version
  hvn                 = module.hcp.hvn
  region              = var.aws_region
  ad_domain           = var.ad_domain
  timezone            = var.timezone
}
