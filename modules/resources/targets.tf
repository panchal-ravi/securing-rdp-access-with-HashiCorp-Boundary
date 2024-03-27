resource "boundary_target" "windows_restricted" {
  type                     = "tcp"
  name                     = "windows_restricted"
  description              = "Windows host access using dynamic creds for the support role. This role should not have access to Windows Control Panel"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 3389
  egress_worker_filter = "\"egress\" in \"/tags/type\""
  address              = aws_instance.windows_client.private_ip

  # Dynamic AD credentials to be generated for each user session
  brokered_credential_source_ids = [boundary_credential_library_vault.windows_restricted.id]
}

resource "boundary_credential_library_vault" "windows_restricted" {
  name                = "windows-dynamic-creds-restricted"
  description         = "Dynamic AD user creds for the support role"
  credential_store_id = boundary_credential_store_vault.cred_store.id
  path                = "ldap/creds/${local.vault_ldap_support_restricted}"
  http_method         = "GET"
  credential_type     = "username_password"
}


resource "boundary_target" "windows_privileged" {
  type                     = "tcp"
  name                     = "windows_privileged"
  description              = "Windows host access using dynamic creds for the default user role. This role should have access to Windows Control Panel"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 3389
  egress_worker_filter = "\"egress\" in \"/tags/type\""
  address              = aws_instance.windows_client.private_ip

  # Dynamic AD credentials to be generated for each user session
  brokered_credential_source_ids = [boundary_credential_library_vault.windows_privileged.id]
}

resource "boundary_credential_library_vault" "windows_privileged" {
  name                = "windows-dynamic-creds-privileged"
  description         = "Dynamic AD user creds for the admin role"
  credential_store_id = boundary_credential_store_vault.cred_store.id
  path                = "ldap/creds/${local.vault_ldap_privileged_rolename}"
  http_method         = "GET"
  credential_type     = "username_password"
}
