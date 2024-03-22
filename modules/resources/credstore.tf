resource "vault_token" "boundary" {
  policies = [vault_policy.boundary_controller.name,
    vault_policy.ldap_creds.name
  ]

  no_parent         = true
  no_default_policy = true
  renewable         = true
  ttl               = "20m"
  period            = "20m"

  metadata = {
    "purpose" = "boundary-service-account"
  }
  depends_on = [time_sleep.wait_for_egress_worker]
}

resource "boundary_credential_store_vault" "cred_store" {
  name        = "vault-cred-store"
  description = "Vault credential store!"
  address     = var.vault_cluster_url
  token       = vault_token.boundary.client_token
  scope_id    = boundary_scope.project.id
  namespace   = local.vault_namespace

  worker_filter = "\"egress\" in \"/tags/type\""

  depends_on = [time_sleep.wait_for_egress_worker]
}


