module "frontend" {
  source = "./modules/cloud_run_v2"

  name       = "${var.name}-frontend"
  project_id = var.project_id

  src_folder       = "../frontend/src"
  src_file_pattern = "*.tsx"
  dockerfile_path  = "../frontend"

  container_port = 3000

  environment_variables = {
    NEXT_PUBLIC_API_URL = "https://api.example.com"
  }
}

module "backend" {
  source = "./modules/cloud_run_v2"

  name       = "${var.name}-backend"
  project_id = var.project_id

  src_folder       = "../backend/app"
  src_file_pattern = "*.go"
  dockerfile_path  = "../backend"

  container_port = 80

  storage_bucket = google_storage_bucket.storage.name
  max_instance_request_concurrency = 1

  environment_variables = {
    GOOGLE_CLOUD_PROJECT_ID = var.project_id
    MOUNT_PATH              = "/mnt/gcs"
  }
}
