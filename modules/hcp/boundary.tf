resource "hcp_boundary_cluster" "this" {
  cluster_id = var.hcp_boundary_cluster_id
  username   = var.hcp_boundary_admin
  password   = var.hcp_boundary_password
  tier       = var.hcp_boundary_tier

  maintenance_window_config {
    day          = "SUNDAY"
    start        = 2
    end          = 12
    upgrade_type = "SCHEDULED"
  }
}