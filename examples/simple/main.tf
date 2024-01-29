module "project" {
  source = "../../"

  name         = "Simple-Project"
  environments = ["staging", "production"]

  google_config = {
    parent = "organizations/174829227356"
  }

  tfe_config = {
    organization = "my-organization"
  }
}
