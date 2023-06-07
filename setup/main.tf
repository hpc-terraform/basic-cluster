provider "google" {
  project     = var.project_id
  region      = var.region
}

resource "google_service_account" "terraform-provision" {
  account_id   = "terraform-provision"
  display_name = "Terraform provision"
  description  = "Permissions needed for HPC Toolkit"
  project      = var.project_id
}

resource "google_service_account" "cluster_permissions" {
  account_id   = "cluster-permissions"
  display_name = "Cluster Permissions Service Account"
  description  = "This service account has the permissions to use storage object viewer and creator along with service account user permissions."
  project = var.project_id
}

resource "google_project_iam_member" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.terraform-provision.email}"
}

resource "google_project_iam_member" "editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform-provision.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.terraform-provision.email}"
}

resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.terraform-provision.email}"
}

resource "google_project_iam_member" "pubsub_admin" {
  project = var.project_id
  role    = "roles/pubsub.admin"
  member  = "serviceAccount:${google_service_account.terraform-provision.email}"
}

resource "google_project_iam_member" "cluster_storage_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cluster_permissions.email}"
}

resource "google_project_iam_member" "cluster_storage_object_creator" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.cluster_permissions.email}"
}

resource "google_project_iam_member" "cluster_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cluster_permissions.email}"
}

resource "google_compute_instance" "default" {
  name         = "terraform-node"
  machine_type = "n1-standard-8"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
      size  = 60
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = google_service_account.terraform-provision.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y git wget make
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    apt update &&  apt install packer
    wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    export HOME=/root
    cd /opt &&\
    git clone https://github.com/GoogleCloudPlatform/hpc-toolkit.git &&\
    echo export PATH=$PATH:/usr/local/go/bin:$HOME/hpc-toolkit >> ~/.bashrc &&\
    cd hpc-toolkit &&\
      make
  EOT
}

