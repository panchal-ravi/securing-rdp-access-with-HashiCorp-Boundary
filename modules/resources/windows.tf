data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

resource "random_password" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
}

resource "aws_instance" "windows" {
  ami                         = data.aws_ami.windows.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [module.windows_sg.security_group_id, module.private-all-windows.security_group_id]
  get_password_data           = true
  
  user_data = templatefile("${path.module}/config/user_data.tpl", {
    DomainName            = var.ad_domain
    ForestMode            = "WinThreshold"
    DomainMode            = "WinThreshold"
    CAKey                 = tls_private_key.ca_private_key.private_key_pem
    CACert                = tls_self_signed_cert.ca_cert.cert_pem
    AdminSafeModePassword = random_password.password.result
    TimeZoneID            = var.timezone
  })

  tags = {
    Name = "${var.deployment_id}-windows-demo"
  }
}

resource "time_sleep" "wait_for_winserver" {
  depends_on      = [aws_instance.windows]
  create_duration = "360s"
}
