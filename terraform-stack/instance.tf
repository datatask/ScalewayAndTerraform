resource "scaleway_instance_security_group" "my_company_security_group" {
  name                   = "my-company-sg"
  inbound_default_policy = "drop"
  external_rules         = true
}

resource "scaleway_instance_server" "team_builder_instance" {
  name              = "team-builder"
  type              = var.team_builder_instance_type
  zone              = var.scw_zone
  image             = "ubuntu_focal"
  security_group_id = scaleway_instance_security_group.my_company_security_group.id
  tags              = ["team-builder"]

  root_volume {
    size_in_gb            = var.team_builder_instance_root_volume_size_in_gb
    delete_on_termination = true
  }
}

resource "scaleway_instance_private_nic" "team_builder_instance_pnic01" {
  server_id          = scaleway_instance_server.team_builder_instance.id
  private_network_id = scaleway_vpc_private_network.my_company_pn.id

  depends_on = [
    scaleway_instance_server.team_builder_instance
  ]
}

resource "time_sleep" "wait_30_seconds_after_team_builder_instance_network_setup" {
  create_duration = "30s"

  depends_on = [
    scaleway_instance_server.team_builder_instance,
    scaleway_lb.my_company_lb,
    scaleway_vpc_public_gateway.my_company_pg,
    scaleway_vpc_public_gateway_dhcp_reservation.my_company_pg_dhcp_res_team_builder_instance,
    scaleway_vpc_public_gateway_pat_rule.my_company_pg_pat_rule_team_builder_instance_ssh
  ]
}

resource "null_resource" "reboot_team_builder_instance_after_network_setup" {
  triggers = {
    my_company_pg_dhcp_res_team_builder_instance_id = scaleway_vpc_public_gateway_dhcp_reservation.my_company_pg_dhcp_res_team_builder_instance.id
  }

  provisioner "local-exec" {
    command = <<EOF
      curl -X POST \
        -H "X-Auth-Token: ${var.scw_secret_key}" \
        -H "Content-Type: application/json" \
        -d '{"action": "reboot"}' \
        https://api.scaleway.com/instance/v1/zones/${var.scw_zone}/servers/${split("/", scaleway_instance_server.team_builder_instance.id)[1]}/action
    EOF
  }

  depends_on = [
    time_sleep.wait_30_seconds_after_team_builder_instance_network_setup
  ]
}

resource "time_sleep" "wait_30_seconds_after_team_builder_instance_reboot" {
  create_duration = "30s"

  depends_on = [
    null_resource.reboot_team_builder_instance_after_network_setup
  ]
}

resource "null_resource" "team_builder_install" {
  connection {
    type        = "ssh"
    host        = scaleway_vpc_public_gateway_ip.my_company_pg_ip.address
    port        = 2202
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "./scripts/install-docker.sh"
    destination = "/tmp/install-docker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-docker.sh",
      "/tmp/install-docker.sh"
    ]
  }

  depends_on = [
    time_sleep.wait_30_seconds_after_team_builder_instance_reboot
  ]
}

resource "null_resource" "team_builder_run" {
  triggers = {
    image              = var.team_builder_container_image
    db_host            = scaleway_rdb_instance.my_company_db_instance.private_network.0.ip
    db_port            = scaleway_rdb_instance.my_company_db_instance.private_network.0.port
    db_user            = var.db_instance_team_builder_user_name
    db_password        = var.db_instance_team_builder_password
    db_name            = scaleway_rdb_database.db.name
    db_schema          = var.team_builder_container_db_schema
    db_employees_table = var.team_builder_container_db_employees_table
  }

  connection {
    type        = "ssh"
    host        = scaleway_vpc_public_gateway_ip.my_company_pg_ip.address
    port        = 2202
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/team-builder"
    ]
  }

  provisioner "file" {
    content = templatefile("templates/team-builder/docker-compose.yml", {
      image = var.team_builder_container_image
    })
    destination = "/opt/team-builder/docker-compose.yml"
  }

  provisioner "file" {
    content = templatefile("templates/team-builder/team-builder.env", {
      db_host            = scaleway_rdb_instance.my_company_db_instance.private_network.0.ip
      db_port            = scaleway_rdb_instance.my_company_db_instance.private_network.0.port
      db_user            = var.db_instance_team_builder_user_name
      db_password        = var.db_instance_team_builder_password
      db_name            = scaleway_rdb_database.db.name
      db_schema          = var.team_builder_container_db_schema
      db_employees_table = var.team_builder_container_db_employees_table
    })
    destination = "/opt/team-builder/team-builder.env"
  }

  provisioner "remote-exec" {
    inline = [
      "docker compose -f /opt/team-builder/docker-compose.yml up -d"
    ]
  }

  depends_on = [
    null_resource.team_builder_install
  ]
}




