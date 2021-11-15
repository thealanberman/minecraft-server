variable "domain" {
  type        = string
  description = "public domain for MC server"
}

variable "subdomain" {
  type        = string
  description = "subdomain for MC server"
  default     = "mc"
}

variable "public_key_file" {
  type        = string
  description = "local path to pub key"
}

variable "allow_ssh_cidr" {
  type        = string
  description = "allow SSH access from this CIDR range (/32 to restrict to a specific IP)"
}

variable "instance_type" {
  type    = string
  default = "t4g.medium"
}

variable "architecture" {
  type        = string
  description = "amd64 or arm64, depending on instance_type"
  default     = "arm64"
}

variable "bucket_prefix" {
  type        = string
  description = "s3 bucket prefix for backups"
}

variable "bucket_key" {
  type        = string
  description = "key for backups"
}

variable "server_jar_url" {
  type    = string
  default = "https://download.getbukkit.org/spigot/spigot-1.17.1.jar"
}

variable "versioning" {
  type        = bool
  description = "Use S3 versioning on the bucket for backups"
  default     = false
}

variable "noncurrent_version_expiration" {
  type    = number
  default = 7
}
