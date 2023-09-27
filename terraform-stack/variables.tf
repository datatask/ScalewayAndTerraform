#
## scaleway
#

variable "scw_access_key" {
  type = string
}

variable "scw_secret_key" {
  type = string
}

variable "scw_organisation" {
  type = string
}

variable "scw_project" {
  type = string
}

variable "scw_region" {
  type    = string
}


variable "scw_zone" {
  type    = string
}


#
## db postgreSQL
#

variable "db_instance_node_type" {
  default = "DB-DEV-S"
  type    = string
}

variable "db_instance_admin_user_name" {
  type = string
}

variable "db_instance_admin_password" {
  type = string
}

variable "db_instance_volume_size_in_gb" {
  default = 20
  type    = number
}

variable "db_instance_team_builder_user_name" {
  type = string
}

variable "db_instance_team_builder_password" {
  type = string
}


#
## team-builder instance
#

variable "team_builder_instance_type" {
  default = "PLAY2-NANO"
  type    = string
}


variable "team_builder_instance_root_volume_size_in_gb" {
  default = 10
  type    = number
}

#
## team-builder container
#

variable "team_builder_container_image" {
  type = string
}

variable "team_builder_container_db_schema" {
  type = string
}

variable "team_builder_container_db_employees_table" {
  type = string
}


#
## load balancer
#

variable "my_company_lb_type" {
  default = "LB-S"
  type    = string
}

#
## ssh
#

variable "ssh_private_key_path" {
  default = "~/.ssh/id_ed25519"
  type    = string
}

