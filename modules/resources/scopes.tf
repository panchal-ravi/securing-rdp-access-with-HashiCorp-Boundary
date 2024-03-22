resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "Digital Channels"
  description              = "Digital Channels Organization"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project" {
  name        = "IT_Support"
  description = "IT Support"
  scope_id    = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}
