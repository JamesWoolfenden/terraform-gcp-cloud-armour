# holden:ignore:HLD_TF_004: its sample for example
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.42.0"
    }
  }
  required_version = ">= 1.5.0"
}
