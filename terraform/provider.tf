terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket  = "[バックエンドに利用するバケット名]"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
