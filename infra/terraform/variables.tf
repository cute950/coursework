variable "cloud_id" {
  description = "cloud_id"
}

variable "folder_id" {
  description = "folder_id"
}

variable "subnet_id" {
  description = "folder_id"
}

variable "image_id" {
  description = "image_id"
}

variable "zone" {
  description = "zone"
  default     = "ru-central1-a"
}

variable "service_account_key_file" {
  description = "service_account_key_file"
}

variable "access_key" {
  description = "key id"
}

variable "secret_key" {
  description = "secret key"
}

variable "public_key_path" {
  description = "public key path"
}

variable "private_key_path" {
  description = "private key path"
}

variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable "token" {
  description = "token"
}

variable "service_account_name" {
  description = "service_account_name"
}

variable "service_account_id" {
  description = "service_account_id"
}
