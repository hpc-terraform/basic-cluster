variable "project_id" {
  description = "Project ID"
  type        = string
}
variable "zone" {
  description = "Region"
  type        = string
  default     = "us-central1-c"
}
variable "region" {
  description = "Region"
  type        = string
  default     = "us-central1"
}

variable "node-name" {
  description = "Name for provisioning node"
  type        = string
  default     = "terraform-node"
}


variable "gcp-workgroup" {
  description = "Name for provisioning node"
  type        = string
}



variable "bucket-ro" {
  description = "Bucket to create with read-only permission"
  type        = string
}


variable "bucket-rw" {
  description = "Bucket to create with read/write permission"
  type        = string
}