output "cloud_run_url" {
  value = google_cloud_run_v2_service.service.uri
}

output "service_name" {
  value = google_cloud_run_v2_service.service.name
}

output "service_location" {
  value = google_cloud_run_v2_service.service.location
}
