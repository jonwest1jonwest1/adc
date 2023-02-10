terraform {
  required_version = ">= 0.13"
}
provider "google" {
  project = var.project_id
  region  = var.region
#  zone    = var.zone
}

# Create a random id
#
resource "random_id" "id" {
  byte_length = 2
}

# Create random password for BIG-IP
#
resource "random_string" "password" {
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}
resource "google_compute_network" "mgmtvpc" {
  name                    = format("%s-mgmtvpc-%s", var.prefix, random_id.id.hex)
  auto_create_subnetworks = false
}
resource "google_compute_network" "extvpc" {
  name                    = format("%s-extvpc-%s", var.prefix, random_id.id.hex)
  auto_create_subnetworks = false
}
resource "google_compute_network" "intvpc" {
  name                    = format("%s-intvpc-%s", var.prefix, random_id.id.hex)
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "mgmt_subnetwork" {
  name          = format("%s-mgmt-%s", var.prefix, random_id.id.hex)
  ip_cidr_range = "10.1.0.0/16"
  region        = var.region
  network       = google_compute_network.mgmtvpc.id
}
resource "google_compute_subnetwork" "external_subnetwork" {
  name          = format("%s-ext-%s", var.prefix, random_id.id.hex)
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.extvpc.id
}

resource "google_compute_subnetwork" "internal_subnetwork" {
  name          = format("%s-int-%s", var.prefix, random_id.id.hex)
  ip_cidr_range = "10.3.0.0/16"
  region        = var.region
  network       = google_compute_network.intvpc.id
}

resource "google_compute_firewall" "mgmt_firewall" {
  name    = format("%s-mgmt-firewall-%s", var.prefix, random_id.id.hex)
  network = google_compute_network.mgmtvpc.id
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8443"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "ext_firewall" {
  name    = format("%s-ext-firewall-%s", var.prefix, random_id.id.hex)
  network = google_compute_network.extvpc.id
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8443"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

data "google_secret_manager_secret_version" "admin-password" {
  provider = google-beta
  project = var.project_id
  secret = var.gcp_secret_name
}

module "bigip" {
  source      = "./modules/terraform-gcp-bigip-module"     
  for_each = var.vms
  vm_name      = each.key
  zone         = lookup(each.value,"zone")
  machine_type = lookup(each.value,"machine_type")
  image = lookup(each.value,"image")
  prefix              = format("%s-3nic", var.prefix)
  project_id          = var.project_id
  service_account     = var.service_account
  mgmt_subnet_ids     = [{ "subnet_id" = google_compute_subnetwork.mgmt_subnetwork.id, "public_ip" = true, "private_ip_primary" = "" }]
  external_subnet_ids = [{ "subnet_id" = google_compute_subnetwork.external_subnetwork.id, "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  internal_subnet_ids = [{ "subnet_id" = google_compute_subnetwork.internal_subnetwork.id, "public_ip" = false, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  sleep_time          = var.sleep_time
  f5_ssh_publickey = var.f5_ssh_publickey
    custom_user_data = templatefile("custom_onboard_big.tmpl",
    {
      onboard_log                       = var.onboard_log
      libs_dir                          = var.libs_dir
      bigip_username                    = var.f5_username
      bigip_password                    = data.google_secret_manager_secret_version.admin-password.secret_data
      gcp_secret_manager_authentication = var.gcp_secret_manager_authentication
      gcp_secret_name                   = var.gcp_secret_name
      ssh_keypair                       = file(var.f5_ssh_publickey)
      INIT_URL                          = var.INIT_URL,
      DO_URL                            = var.DO_URL,
      DO_VER                            = split("/", var.DO_URL)[7]
      AS3_URL                           = var.AS3_URL,
      AS3_VER                           = split("/", var.AS3_URL)[7]
      TS_VER                            = split("/", var.TS_URL)[7]
      TS_URL                            = var.TS_URL,
      CFE_VER                           = split("/", var.CFE_URL)[7]
      CFE_URL                           = var.CFE_URL,
      FAST_URL                          = var.FAST_URL
      FAST_VER                          = split("/", var.FAST_URL)[7]
      NIC_COUNT                         = false
  })
}
