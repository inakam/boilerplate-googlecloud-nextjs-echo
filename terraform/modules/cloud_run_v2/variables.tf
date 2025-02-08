variable "name" {
  description = "The name of the image to create"
}

variable "project_id" {
  description = "The project ID to deploy the image to"
}

variable "src_folder" {
  description = "The folder path to the source code"
}

variable "src_file_pattern" {
  description = "The file pattern to include in the source code"
  default     = "*"
}

variable "dockerfile_path" {
  description = "The path to the Dockerfile"
}

variable "image_tag" {
  default     = "latest"
  description = "The tag of the image to create"
}

variable "region" {
  description = "The region to deploy the service to"
  default     = "asia-northeast1"
}

variable "environment_variables" {
  description = "The environment variables to set for the function"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "The port the container listens on"
}

variable "storage_bucket" {
  description = "The bucket to mount"
  default = null
}

variable "max_instance_request_concurrency" {
  description = "The maximum number of requests that can be sent to an instance at any given time"
  default     = 5
}
