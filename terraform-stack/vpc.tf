resource "scaleway_vpc_private_network" "my_company_pn" {
  name = "my-company-pn"
}

resource "scaleway_vpc_public_gateway_dhcp" "my_company_dhcp" {
  subnet             = "192.168.0.0/24"
  push_default_route = true
  enable_dynamic     = false
  pool_low           = "192.168.0.20"
  pool_high          = "192.168.0.249"
}

resource "scaleway_vpc_public_gateway_ip" "my_company_pg_ip" {}

resource "scaleway_vpc_public_gateway" "my_company_pg" {
  name  = "my-company-pg"
  type  = "VPC-GW-S"
  ip_id = scaleway_vpc_public_gateway_ip.my_company_pg_ip.id
}

resource "scaleway_vpc_gateway_network" "my_company_gn" {
  gateway_id         = scaleway_vpc_public_gateway.my_company_pg.id
  private_network_id = scaleway_vpc_private_network.my_company_pn.id
  dhcp_id            = scaleway_vpc_public_gateway_dhcp.my_company_dhcp.id
  cleanup_dhcp       = true
  enable_masquerade  = true

  depends_on = [
    scaleway_vpc_public_gateway_ip.my_company_pg_ip,
    scaleway_vpc_public_gateway.my_company_pg,
    scaleway_vpc_private_network.my_company_pn
  ]
}

resource "scaleway_vpc_public_gateway_dhcp_reservation" "my_company_pg_dhcp_res_team_builder_instance" {
  gateway_network_id = scaleway_vpc_gateway_network.my_company_gn.id
  mac_address        = scaleway_instance_private_nic.team_builder_instance_pnic01.mac_address
  ip_address         = "192.168.0.10"

  depends_on = [
    scaleway_vpc_public_gateway_dhcp.my_company_dhcp,
    scaleway_vpc_gateway_network.my_company_gn,
    scaleway_instance_private_nic.team_builder_instance_pnic01
  ]
}

resource "scaleway_vpc_public_gateway_pat_rule" "my_company_pg_pat_rule_team_builder_instance_ssh" {
  gateway_id   = scaleway_vpc_public_gateway.my_company_pg.id
  private_ip   = scaleway_vpc_public_gateway_dhcp_reservation.my_company_pg_dhcp_res_team_builder_instance.ip_address
  private_port = 22
  public_port  = 2202
  protocol     = "tcp"

  depends_on = [
    scaleway_vpc_gateway_network.my_company_gn,
    scaleway_vpc_private_network.my_company_pn
  ]
}
