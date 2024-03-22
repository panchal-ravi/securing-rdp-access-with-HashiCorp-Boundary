data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.6.0"

  name                 = var.deployment_id
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

data "aws_arn" "peer" {
  arn = module.vpc.vpc_arn
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id          = var.hvn.hvn_id
  peering_id      = "${var.deployment_id}-peering"
  peer_vpc_id     = module.vpc.vpc_id
  peer_account_id = module.vpc.vpc_owner_id
  peer_vpc_region = data.aws_arn.peer.region
}

resource "hcp_hvn_route" "peer_route" {
  hvn_link         = var.hvn.self_link
  hvn_route_id     = "${var.deployment_id}-route"
  destination_cidr = var.vpc_cidr
  target_link      = hcp_aws_network_peering.peer.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}

data "aws_route_tables" "main_vpc_rts" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_route" "public_rt" {
  route_table_id            = module.vpc.public_route_table_ids[0]
  destination_cidr_block    = var.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}

resource "aws_route" "private_rt" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = var.hvn.cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}