/* Define a Boundary worker. The worker_generated_auth_token should
always be left as "" if you are deploying a Controller-led authorisation flow.
This will result in the controller generating the one-time token to use, that must be
passed into the worker configuration file.
*/
resource "boundary_worker" "self_managed_pki_worker" {
  scope_id                    = "global"
  name                        = "bounday-aws-worker"
  worker_generated_auth_token = ""
}

/* This locals block sets out the configuration for the Boundary Service file and 
the HCL configuration for the PKI Worker. Within the boundary_egress_worker_hcl_config
the controller_generated_activation_token pulls in the one-time token generated by the 
boundary_worker resource above.

The cloud_init config takes the content of the two configurations and specifies the path
on the EC2 instance to write to.
*/
locals {
  boundary_self-managed_worker_service_config = <<-WORKER_SERVICE_CONFIG
  [Unit]
  Description="HashiCorp Boundary - Identity-based access management for dynamic infrastructure"
  Documentation=https://www.boundaryproject.io/docs
  #StartLimitIntervalSec=60
  #StartLimitBurst=3

  [Service]
  EnvironmentFile=-/etc/boundary.d/boundary.env
  User=boundary
  Group=boundary
  ProtectSystem=full
  ProtectHome=read-only
  ExecStart=/usr/bin/boundary-worker server -config=/etc/boundary.d/pki-worker.hcl
  ExecReload=/bin/kill --signal HUP $MAINPID
  KillMode=process
  KillSignal=SIGINT
  Restart=on-failure
  RestartSec=5
  TimeoutStopSec=30
  LimitMEMLOCK=infinity

  [Install]
  WantedBy=multi-user.target
  WORKER_SERVICE_CONFIG

  boundary_self-managed_worker_hcl_config = <<-WORKER_HCL_CONFIG
  disable_mlock = true

  hcp_boundary_cluster_id = "${split(".", split("//", var.boundary_addr)[1])[0]}"

  listener "tcp" {
    address = "0.0.0.0:9202"
    purpose = "proxy"
  }

  worker {
    public_addr = "file:///tmp/ip"
    auth_storage_path = "/etc/boundary.d/worker"
    recording_storage_path = "/etc/boundary.d/sessionrecord"
    controller_generated_activation_token = "${boundary_worker.self_managed_pki_worker.controller_generated_activation_token}"
    tags {
      type = ["self-managed-aws-worker"]
    }
  }
WORKER_HCL_CONFIG

  cloudinit_config_boundary_self-managed_worker = {
    write_files = [
      {
        content = local.boundary_self-managed_worker_service_config
        path    = "/usr/lib/systemd/system/boundary.service"
      },

      {
        content = local.boundary_self-managed_worker_hcl_config
        path    = "/etc/boundary.d/pki-worker.hcl"
      },
    ]
  }
}

/* This data block pulls in all the different parts of the configuration to be deployed.
These are executed in the order that they are written. Firstly, the boundary-worker binary
will be called. Secondly, the configuration specified in the locals block will be called.
Lastly the boundary-worker process is started using the pki-worker.hcl file.
*/
data "cloudinit_config" "boundary_self-managed_worker" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      sudo yum install -y shadow-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      sudo yum -y install boundary-enterprise
      curl 'https://api.ipify.org?format=txt' > /tmp/ip
      sudo mkdir /etc/boundary.d/sessionrecord
  EOF
  }
  part {
    content_type = "text/cloud-config"
    content      = yamlencode(local.cloudinit_config_boundary_self-managed_worker)
  }
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    sudo boundary server -config="/etc/boundary.d/pki-worker.hcl"
    EOF
  }
}

/* Create the Boundary worker instance and specify the data block in the user_data_base64
parameter. The depends_on argument is set to ensure that the networking is establish first
and that the boundary_worker resource also completes, to ensure the token is generated first.
*/
resource "aws_instance" "boundary_self_managed_worker" {
  ami                         = "ami-09ee0944866c73f62"
  instance_type               = "t2.micro"
  availability_zone           = "eu-west-2b"
  user_data_replace_on_change = true
  user_data_base64            = data.cloudinit_config.boundary_self-managed_worker.rendered
  key_name                    = "boundary"
  private_ip                  = "172.31.32.93"
  subnet_id                   = aws_subnet.boundary_demo_subnet.id
  vpc_security_group_ids      = [aws_security_group.boundary_ingress_worker_ssh.id]
  tags = {
    Name = "Boundary Self-Managed Worker"
  }
}