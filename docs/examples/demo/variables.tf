variable "project" {
  description = "The project ID for the network"
  type        = string
}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across a project."
  type        = string
}
