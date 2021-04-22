terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.65.0"
    }
  }
}

provider "google" {

  credentials = file("myterraapp-ce5aa4acd603.json")

  project = "myterraapp"
  region  = "europe-central2"
  zone    = "europe-central2-a"
}



resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}


resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "master" {
  name = "master-instance-${random_id.db_name_suffix.hex}"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.master.name
}

resource "google_sql_user" "users" {
  name     = "user"
  instance = google_sql_database_instance.master.name
  password = "Eey3ar8fz343uciy"
}


data "google_cloud_run_locations" "available" {
}