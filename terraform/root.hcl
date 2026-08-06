locals {
  region                  = "eu-frankfurt-1"
  object_storage_endpoint = "https://frx6hbt3t4bu.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
  bucket_name             = "kishu-tf-state"
}

# Automatically generate the backend configuration for every child module
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket                      = "${local.bucket_name}"
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    region                      = "${local.region}"
    endpoint                    = "${local.object_storage_endpoint}"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
  }
}
EOF
}

# Automatically generate the OCI provider configuration for every child module
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}
EOF
}

# Shared variables automatically injected into all child modules
inputs = {
  project_prefix   = "kishu"
  tenancy_ocid     = get_env("TF_VAR_tenancy_ocid")
  user_ocid        = get_env("TF_VAR_user_ocid")
  fingerprint      = get_env("TF_VAR_fingerprint")
  private_key      = get_env("TF_VAR_private_key")
  region           = get_env("TF_VAR_region")
  compartment_ocid = get_env("TF_VAR_compartment_ocid")
}

# Common variables automatically injected into all child modules
generate "common_variables" {
  path      = "common_variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
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
EOF
}