variable "project_id" {
  description = "The project ID to deploy into"
  default = "[自分のGCPプロジェクトID]"
}

variable "region" {
  description = "The region to deploy into"
  default = "asia-northeast1"
}

variable "environment" {
  description = "The environment to deploy into"
  default = "dev"
}

variable "name" {
  description = "The product to deploy"
  default = "cloud-run"
}
