terraform {
  backend "s3" {
    key                         = "infrastructure/terraform.tfstate"
    region                      = "eu-frankfurt-1"

    # OCI S3-Compatibility Endpoint
    endpoint                    = "https://frx6hbt3t4bu.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"

    # Mandatory flags required for OCI S3 emulation
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}