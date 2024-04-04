resource "vault_ldap_secret_backend" "config" {
  path         = "ldap"
  binddn       = "CN=Administrator,CN=Users,DC=${split(".", var.ad_domain)[0]},DC=${split(".", var.ad_domain)[1]}"
  bindpass     = rsadecrypt(aws_instance.windows.password_data, tls_private_key.ssh.private_key_pem)
  url          = "ldaps://${aws_instance.windows.private_ip}"
  insecure_tls = "true"
  certificate  = tls_self_signed_cert.ca_cert.cert_pem
  schema       = "ad"
}

#Vault dynamic role to create AD credentials for "admin" role
#User account management is provided through LDIF entries
resource "vault_ldap_secret_backend_dynamic_role" "privileged" {
  mount         = vault_ldap_secret_backend.config.path
  creation_ldif = templatefile("${path.module}/config/creation.tpl.ldif", {
    domain_prefix = split(".", var.ad_domain)[0]
    domain_suffix = split(".", var.ad_domain)[1]
  })
  deletion_ldif = templatefile("${path.module}/config/deletion.tpl.ldif", {
    domain_prefix = split(".", var.ad_domain)[0]
    domain_suffix = split(".", var.ad_domain)[1]
  })
  username_template = "v_{{.RoleName}}_{{random 5}}"
  role_name         = local.vault_ldap_privileged_rolename
  default_ttl       = 600
  max_ttl           = 1200
}

#Vault dynamic role to create AD credentials for "support" role
resource "vault_ldap_secret_backend_dynamic_role" "support" {
  mount         = vault_ldap_secret_backend.config.path
  creation_ldif = templatefile("${path.module}/config/creation_restricted.tpl.ldif", {
    domain_prefix = split(".", var.ad_domain)[0]
    domain_suffix = split(".", var.ad_domain)[1]
    ad_group_name = local.ad_group_name
  })
  deletion_ldif = templatefile("${path.module}/config/deletion.tpl.ldif", {
    domain_prefix = split(".", var.ad_domain)[0]
    domain_suffix = split(".", var.ad_domain)[1]
  })
  username_template = "v_{{.RoleName}}_{{random 5}}"
  role_name         = local.vault_ldap_support_rolename
  default_ttl       = 600
  max_ttl           = 1200
}

