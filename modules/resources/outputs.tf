output "boundary_user_password" {
  sensitive = true
  value     = random_password.user_password.result
}