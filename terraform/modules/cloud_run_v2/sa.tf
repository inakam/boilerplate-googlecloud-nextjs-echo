resource "google_service_account" "cloud_run" {
  account_id = "${var.name}-sa"
  project    = var.project_id
}

# サービスアカウントにGCSアクセス権限を付与
resource "google_project_iam_member" "storage" {
  count  = var.storage_bucket == null ? 0 : 1
  project = var.project_id
  role    = "roles/storage.objectUser"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}
