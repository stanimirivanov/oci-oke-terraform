terraform {
  backend "s3" {
    key                         = "01-infrastructure/terraform.tfstate"
    region                      = "eu-frankfurt-1"
    endpoint                    = "https://ax1b2c3d4e5f.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}