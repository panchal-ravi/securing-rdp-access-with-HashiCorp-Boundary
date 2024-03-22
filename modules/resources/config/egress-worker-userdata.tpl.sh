#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install unzip -y

curl -k -O https://releases.hashicorp.com/boundary/${boundary_version}/boundary_${boundary_version}_linux_amd64.zip
unzip boundary_${boundary_version}_linux_amd64.zip
mv boundary /usr/bin/boundary
mkdir -p /etc/boundary.d/auth_storage

export private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo "---------------Creating boundary-worker.hcl------------------"
cat << EOF > /etc/boundary.d/boundary-worker.hcl
disable_mlock = true
hcp_boundary_cluster_id = "${hcp_boundary_cluster_id}"

listener "tcp" {
    address = "$private_ip:9202"
    purpose = "proxy"
    tls_disable = true
}

worker {
    # Name attr must be unique
    public_addr = "$private_ip"
    auth_storage_path = "/etc/boundary.d/auth_storage"
    controller_generated_activation_token = "${activation_token}"
    tags {
        type = ["egress", "self-managed"]
    }
}
EOF

echo "---------------Creating boundary-worker.service------------------"
cat << EOF > /etc/systemd/system/boundary-worker.service
[Unit]
Description=boundary worker

[Service]
ExecStart=/usr/bin/boundary server -config /etc/boundary.d/boundary-worker.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
adduser --system --group boundary || true
chown -R boundary:boundary /etc/boundary.d
chown boundary:boundary /usr/bin/boundary
chmod 664 /etc/systemd/system/boundary-worker.service
systemctl daemon-reload
systemctl enable boundary-worker


systemctl start boundary-worker
sleep 10


