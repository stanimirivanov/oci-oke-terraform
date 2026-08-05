locals {
  region                  = "eu-frankfurt-1"
  object_storage_endpoint = "https://ax1b2c3d4e5f.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
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
    force_path_style            = true
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
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
EOF
}

# Shared variables automatically injected into all child modules
inputs = {
  project_prefix   = "kishu"
  tenancy_ocid     = get_env("TF_VAR_tenancy_ocid")
  user_ocid        = get_env("TF_VAR_user_ocid")
  fingerprint      = get_env("TF_VAR_fingerprint")
  private_key_path = "~/.oci/oci_api_key.pem"
  region           = "eu-frankfurt-1"
  compartment_ocid = get_env("TF_VAR_compartment_ocid")
}