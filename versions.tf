terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.7"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}
