variable "yc_token" {
  description = "Yandex Cloud API token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Yandex Cloud Zone"
  type        = string
  default     = "ru-central1-a"
}

variable "project_name" {
  description = "Project name, used as a prefix for resources"
  type        = string
  default     = "devops-cv"
}

variable "domain" {
  description = "Domain name for the project"
  type        = string
  default     = "zolotarev.tech"
}

variable "vm_image_id" {
  description = "VM image ID (Ubuntu 20.04)"
  type        = string
  default     = "fd8emvfmfoaordspe1jr" # Ubuntu 20.04 LTS
}

variable "vm_user" {
  description = "Username for VM SSH access"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
  sensitive   = true
}
