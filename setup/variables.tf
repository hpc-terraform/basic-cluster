variable "project_id" {
  description = "Project ID"
  type        = string
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




