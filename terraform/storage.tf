resource "google_storage_bucket" "storage" {
  name     = "${var.name}-backend-storage"
  location = var.region
  storage_class = "STANDARD"

  force_destroy = true
}
