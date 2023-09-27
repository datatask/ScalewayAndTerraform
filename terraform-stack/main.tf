terraform {
  required_version = "~>1.0"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.16.3"
    }
  }
}

provider "scaleway" {
  access_key      = var.scw_access_key
  secret_key      = var.scw_secret_key
  organization_id = var.scw_organisation
  project_id      = var.scw_project
  zone            = var.scw_zone
  region          = var.scw_region
}


