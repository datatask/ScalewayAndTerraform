resource "scaleway_rdb_instance" "my_company_db_instance" {
  name          = "database"
  node_type     = var.db_instance_node_type
  engine        = "PostgreSQL-14"
  is_ha_cluster = false
  user_name     = var.db_instance_admin_user_name
  password      = var.db_instance_admin_password

  volume_type       = "bssd"
  volume_size_in_gb = var.db_instance_volume_size_in_gb

  disable_backup            = false
  backup_schedule_frequency = 24 # every day
  backup_schedule_retention = 7  # keep it one week

  private_network {
    ip_net = "192.168.0.254/24" #pool high
    pn_id  = scaleway_vpc_private_network.my_company_pn.id
  }
}

resource "scaleway_rdb_acl" "my_private_network_acl" {
  instance_id = scaleway_rdb_instance.my_company_db_instance.id
  acl_rules {
    ip = "192.168.0.0/24"
    description = "my_private_network"
  }
}

resource "scaleway_rdb_database" "db" {
  instance_id = scaleway_rdb_instance.my_company_db_instance.id
  name        = "companies"
}


resource "scaleway_rdb_user" "db_team_builder_user" {
  instance_id = scaleway_rdb_instance.my_company_db_instance.id
  name        = var.db_instance_team_builder_user_name
  password    = var.db_instance_team_builder_password
  is_admin    = false
}

resource "scaleway_rdb_privilege" "db_admin_user_privilege" {
  instance_id   = scaleway_rdb_instance.my_company_db_instance.id
  user_name     = var.db_instance_admin_user_name
  database_name = scaleway_rdb_database.db.name
  permission    = "all"

  depends_on = [
    scaleway_rdb_instance.my_company_db_instance,
    scaleway_rdb_database.db
  ]
}

resource "scaleway_rdb_privilege" "db_team_builder_user_privilege" {
  instance_id   = scaleway_rdb_instance.my_company_db_instance.id
  user_name     = var.db_instance_team_builder_user_name
  database_name = scaleway_rdb_database.db.name
  permission    = "all"

  depends_on = [
    scaleway_rdb_instance.my_company_db_instance,
    scaleway_rdb_database.db,
    scaleway_rdb_user.db_team_builder_user
  ]
}
