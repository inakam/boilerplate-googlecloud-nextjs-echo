# イメージをPUSHするためのリポジトリ情報
locals {
  registry_url = "${google_artifact_registry_repository.registry.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.registry.name}/${var.name}:${var.image_tag}"
}

# DockerイメージをビルドしてGCRにプッシュするためのnull_resource
resource "null_resource" "build_and_push_image" {
  triggers = {
    code_diff = sha512(join("", [
      for file in fileset(var.src_folder, "**/${var.src_file_pattern}")
      : filesha256("${var.src_folder}/${file}")
    ]))
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker build --platform linux/amd64 -t ${local.registry_url} .
      docker push ${local.registry_url}
    EOT
    working_dir = var.dockerfile_path
  }
}

# Cloud Run v2でサービスを作成する
resource "google_cloud_run_v2_service" "service" {
  name     =  "${var.name}-service"
  location = var.region
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run.email
    containers {
      image = local.registry_url
      resources {
        limits = {
          cpu    = "2"
          memory = "1024Mi"
        }
      }
      ports {
        container_port = var.container_port
      }
      env {
        name = "code_diff"
        value = null_resource.build_and_push_image.triggers.code_diff
      }
      dynamic env {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }
      dynamic volume_mounts {
        for_each = var.storage_bucket != null && var.storage_bucket != "" ? [1] : []
        content {
          name       = "gcs"
          mount_path = "/mnt/gcs"
        }
      }
    }

    dynamic volumes {
      for_each = var.storage_bucket != null && var.storage_bucket != "" ? [1] : []
      content {
        name = "gcs"
        gcs {
          bucket = var.storage_bucket
          read_only = false
        }
      }
    }

    timeout = "10s"
    max_instance_request_concurrency = var.max_instance_request_concurrency
  }

  # null_resourceに依存させることで、DockerイメージのビルドとプッシュがGCRに完了した後にCloud Runサービスが作成されるようにする
  depends_on = [
    google_artifact_registry_repository.registry,
    null_resource.build_and_push_image,
  ]

  deletion_protection = false
}

data "google_iam_policy" "no_auth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth" {
  location = google_cloud_run_v2_service.service.location
  project  = google_cloud_run_v2_service.service.project
  service  = google_cloud_run_v2_service.service.name

  policy_data = data.google_iam_policy.no_auth.policy_data
}
