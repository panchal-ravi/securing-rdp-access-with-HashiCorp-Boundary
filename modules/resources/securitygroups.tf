module "egress_worker_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.deployment_id}-egress-worker"
  description = "Traffic to/from egress worker"
  vpc_id      = module.vpc.vpc_id

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "windows_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-private-win"
  description = "Allow private inbound from vault and egress-worker "
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Allow ldap-tls from HVN"
      cidr_blocks = var.hvn.cidr_block
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "rdp-tcp"
      source_security_group_id = module.egress_worker_sg.security_group_id
    }
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


module "private-all-windows" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-private-win"
  description = "Allow all between Windows DC and Windows clients"
  vpc_id      =  module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.windows_sg.security_group_id
    }
  ]

}

