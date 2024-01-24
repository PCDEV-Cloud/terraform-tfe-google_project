module "project" {
  source = "github.com/PCDEV-Cloud/terraform-tfe-google_project"

  name         = "Simple-Project"
  environments = ["staging", "production"]

  google_config = {
    parent = "organizations/174829227356"
  }

  tfe_config = {
    organization = "my-organization"
  }
}
