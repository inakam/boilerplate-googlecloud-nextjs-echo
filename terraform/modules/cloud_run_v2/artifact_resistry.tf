# Artifact Registryリポジトリを作成
resource "google_artifact_registry_repository" "registry" {
  location      = "us-east1"
  repository_id = "${var.name}-repo"
  description   = "CloudRun Docker image repository"
  format        = "DOCKER"
}
