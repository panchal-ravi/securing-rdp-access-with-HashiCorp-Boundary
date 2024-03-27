data "boundary_auth_method" "global_auth_method" {
  name = "password"
}

resource "random_password" "user_password" {
  length           = 12
  special          = true
  override_special = "!@#$%"
}

resource "boundary_account_password" "support" {
  auth_method_id = data.boundary_auth_method.global_auth_method.id
  login_name     = local.boundary_support_username
  password       = random_password.user_password.result
}

resource "boundary_user" "support" {
  name        = local.boundary_support_username
  description = "Support user"
  account_ids = [boundary_account_password.support.id]
  scope_id    = "global"
}

resource "boundary_role" "default_org" {
  name           = "default_org"
  scope_id       = "global"
  grant_scope_id = "global"
  grant_strings = [
    "ids=${boundary_scope.project.id};actions=read",
    "ids={{.User.Id}};actions=read",
    "ids=*;type=auth-token;actions=list,read:self,delete:self"
  ]
  principal_ids = [boundary_user.support.id]
}

resource "boundary_role" "default_project" {
  name           = "default_project"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=*;type=session;actions=list,no-op",
    "ids=*;type=session;actions=read:self,cancel:self",
  ]
  principal_ids = [boundary_user.support.id]
}

resource "boundary_role" "support" {
  name            = "support"
  description     = "Access to Windows hosts using dynamic AD creds with restricted permissions"
  scope_id        = boundary_scope.org.id
  grant_scope_ids = ["children"]
  grant_strings   = [
    "ids=${boundary_target.windows_restricted.id};actions=read,authorize-session",
    "ids=*;type=target;actions=list,no-op",
  ]
  principal_ids = [boundary_user.support.id]
}
