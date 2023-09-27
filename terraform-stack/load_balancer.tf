
resource "scaleway_lb_ip" "my_company_lb_ip" {}

resource "scaleway_lb" "my_company_lb" {
  name  = "load-balancer"
  ip_id = scaleway_lb_ip.my_company_lb_ip.id
  zone  = var.scw_zone
  type  = var.my_company_lb_type

  private_network {
    private_network_id = scaleway_vpc_private_network.my_company_pn.id
    dhcp_config        = true
  }

  depends_on = [
    scaleway_vpc_public_gateway.my_company_pg
  ]
}

resource "scaleway_lb_backend" "my_company_lb_backend" {
  lb_id            = scaleway_lb.my_company_lb.id
  name             = "team-builder-backend"
  forward_protocol = "http"
  forward_port     = "8080"
  server_ips       = [scaleway_vpc_public_gateway_dhcp_reservation.my_company_pg_dhcp_res_team_builder_instance.ip_address]

  health_check_http {
    uri    = "http://${scaleway_lb_ip.my_company_lb_ip.ip_address}/health"
    method = "GET"
    code   = 200
  }

  depends_on = [
    scaleway_instance_server.team_builder_instance
  ]
}

resource "scaleway_lb_frontend" "my_company_lb_frontend" {
  lb_id           = scaleway_lb.my_company_lb.id
  backend_id      = scaleway_lb_backend.my_company_lb_backend.id
  name            = "team-builder-frontend"
  inbound_port    = "80"
}
