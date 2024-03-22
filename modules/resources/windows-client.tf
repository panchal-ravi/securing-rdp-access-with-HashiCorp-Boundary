resource "aws_instance" "windows_client" {
  ami                         = data.aws_ami.windows.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [module.windows_sg.security_group_id, module.private-all-windows.security_group_id]
  get_password_data           = true

  user_data = templatefile("${path.module}/config/user_data_client.tpl", {
    private_ip     = aws_instance.windows.private_ip
    TimeZoneID     = var.timezone
    DomainName     = var.ad_domain
    DomainUser     = "Administrator"
    DomainPassword = replace(rsadecrypt(aws_instance.windows.password_data, tls_private_key.ssh.private_key_pem), "$", "`$")
  })

  tags = {
    Name = "${var.deployment_id}-windowsclient-demo"
  }
  depends_on = [time_sleep.wait_for_winserver]
}
