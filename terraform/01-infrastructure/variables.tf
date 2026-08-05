variable "project_prefix" {
  description = "Prefix applied to all provisioned OCI resources"
  type        = string
  default     = "kishu"
}

variable "tenancy_ocid" {
  description = "OCID of the OCI Tenancy"
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
  description = "OCI Region (e.g. eu-frankfurt-1, us-ashburn-1)"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the OCI Compartment where resources are provisioned"
  type        = string
}