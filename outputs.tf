output "boundary_cluster_url" {
  value = module.hcp.boundary_cluster_url
}
output "vault_cluster_public_url" {
  value = module.hcp.vault_public_endpoint_url
}
output "vault_cluster_admin_token" {
  sensitive = true
  value     = module.hcp.vault_admin_token
}
output "boundary_user_password" {
  sensitive = true
  value     = module.resources.boundary_user_password
}