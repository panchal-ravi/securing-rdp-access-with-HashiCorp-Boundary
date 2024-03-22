resource "boundary_target" "windows_dynamic" {
  type                     = "tcp"
  name                     = "windows_dynamic"
  description              = "Windows host access using dynamic creds"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 3389
  default_client_port      = 3389
  egress_worker_filter = "\"egress\" in \"/tags/type\""
  address              = aws_instance.windows_client.private_ip

  brokered_credential_source_ids = [boundary_credential_library_vault.windows_dynamic_creds.id]
}

resource "boundary_credential_library_vault" "windows_dynamic_creds" {
  name                = "windows-dynamic-creds"
  description         = "Dynamic AD user creds"
  credential_store_id = boundary_credential_store_vault.cred_store.id
  path                = "ldap/creds/${local.vault_ldap_rolename}"
  http_method         = "GET"
  credential_type     = "username_password"
}
