variable "cluster_id" {
  description = "OCID of the OKE cluster created in Stage 1"
  type        = string
}

variable "project_prefix" {
  description = "Prefix applied to resources"
  type        = string
  default     = "kishu"
}

variable "tenancy_ocid" {
  description = "OCID of your OCI Tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI IAM User"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API key"
  type        = string
}

variable "private_key" {
  description = "PEM contents of the OCI API signing key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI Region"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the OCI Compartment"
  type        = string
}