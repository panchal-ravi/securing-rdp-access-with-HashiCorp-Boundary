output "boundary_cluster_url" {
  value = hcp_boundary_cluster.this.cluster_url
}

output "vault_public_endpoint_url" {
  value = hcp_vault_cluster.this.vault_public_endpoint_url
}

output "vault_private_endpoint_url" {
  value = hcp_vault_cluster.this.vault_private_endpoint_url
}

output "vault_admin_token" {
  value = hcp_vault_cluster_admin_token.this.token
}

output "boundary_cluster_id" {
  value = trimprefix(split(".", hcp_boundary_cluster.this.cluster_url)[0], "https://")
}

output "hvn" {
  value = {
    hvn_id = hcp_hvn.this.hvn_id
    self_link = hcp_hvn.this.self_link
    cidr_block = hcp_hvn.this.cidr_block
  }
}
