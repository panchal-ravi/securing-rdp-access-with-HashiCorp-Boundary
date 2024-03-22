resource "hcp_hvn" "this" {
  hvn_id         = var.hvn_id
  cloud_provider = "aws"
  region         = var.region
}
