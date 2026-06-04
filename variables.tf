variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "DB_PASSWORD" {
  description = "Password for the MySQL database"
  type        = string
  sensitive   = true
}

variable "DB_USER" {
  description = "Username for the MySQL database"
  type        = string
  sensitive   = true
}

variable "DB_NAME" {
  description = "Name of the MySQL database"
  type        = string
  sensitive   = true
}