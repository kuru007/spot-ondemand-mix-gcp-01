variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region for resources"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zone for cluster"
  default     = "us-central1-a"
}

variable "env" {
  type        = string
  description = "Environment name (test, uat, prod, etc.)"
  default     = "test"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "pods_cidr" {
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  type        = string
  default     = "10.2.0.0/20"
}

variable "cluster_name" {
  type        = string
  default     = "test-cluster"
}

variable "ondemand_machine_type" {
  type        = string
  default     = "e2-medium" # balanced
}

variable "ondemand_node_count" {
  type        = number
  default     = 1
}

variable "spot_machine_type" {
  type        = string
  default     = "e2-micro" # cheap, good for spot
}

variable "spot_node_count" {
  type        = number
  default     = 1
}
