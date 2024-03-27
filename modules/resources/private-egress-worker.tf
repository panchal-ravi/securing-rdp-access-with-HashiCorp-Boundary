data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  key_name   = "${var.deployment_id}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "boundary_worker" "egress_worker" {
  description                 = "self-managed egress worker"
  name                        = "egress-worker"
  scope_id                    = "global"
  worker_generated_auth_token = ""
}

resource "aws_instance" "egress_worker" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.this.key_name
  subnet_id       = element(module.vpc.private_subnets, 1)
  security_groups = [module.egress_worker_sg.security_group_id]

  user_data = templatefile("${path.module}/config/egress-worker-userdata.tpl.sh", {
    hcp_boundary_cluster_id = var.boundary_cluster_id,
    activation_token        = boundary_worker.egress_worker.controller_generated_activation_token,
    boundary_version        = var.boundary_version
  })

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "${var.deployment_id}-worker-egress"
  }
}

resource "time_sleep" "wait_for_egress_worker" {
  depends_on      = [aws_instance.egress_worker]
  create_duration = "210s"
}
