resource "hcp_boundary_cluster" "this" {
  cluster_id = var.hcp_boundary_cluster_id
  username   = var.hcp_boundary_admin
  password   = var.hcp_boundary_password
  tier       = "Plus"
}