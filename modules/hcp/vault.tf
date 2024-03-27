resource "hcp_vault_cluster" "this" {
  hvn_id     = hcp_hvn.this.hvn_id
  cluster_id = var.hcp_vault_cluster_id
  tier       = var.hcp_vault_tier
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "this" {
  cluster_id = hcp_vault_cluster.this.cluster_id
}