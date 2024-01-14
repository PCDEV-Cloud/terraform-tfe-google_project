module "project" {
  source = "github.com/PCDEV-Cloud/terraform-tfe-google_project?ref=v1.0.1"

  name         = "Example-Project"
  environments = ["staging", "production"]

  google_config = {
    parent          = "organizations/174829227356"
    billing_account = "my-billing-account"

    randomize_project_id         = true
    randomize_identity_pool_id   = true
    randomize_provider_id        = true
    randomize_service_account_id = true

    staging = {
      skip_delete            = false
      create_default_network = true

      labels = {
        my-additional-label = "staging"
      }

      apis_and_services = [
        "container.googleapis.com",
        "compute.googleapis.com"
      ]
    }

    production = {
      skip_delete            = true
      create_default_network = false

      labels = {
        my-additional-label = "production"
      }

      apis_and_services = [
        "container.googleapis.com",
        "compute.googleapis.com"
      ]
    }
  }

  tfe_config = {
    organization = "my-organization"

    staging = {
      description                 = "Custom description for staging environment of Example-Project"
      execution_mode              = "local"
      apply_method                = "auto"
      terraform_version           = "1.6.0"
      terraform_working_directory = "/terraform/projects/example-project/staging"
      ssh_key                     = null
      allow_destroy_plan          = true

      version_control = null

      tags = ["local"]

      variables = [
        {
          key         = "execution_mode"
          value       = "local"
          description = "CLI-Driven workspace."
        }
      ]
    }

    production = {
      description                 = "Custom description for production environment of Example-Project"
      execution_mode              = "remote"
      apply_method                = "auto"
      terraform_version           = "1.6.0"
      terraform_working_directory = "/terraform/projects/example-project/production"
      ssh_key                     = null
      allow_destroy_plan          = true

      version_control = {
        name                        = "GitHub"
        repository                  = "my-github/my-repository"
        branch                      = "main"
        include_submodules          = true
        automatic_speculative_plans = true

        triggers = {
          type  = "path_patterns"
          paths = ["terraform/**/*"]
        }
      }

      tags = ["remote"]

      variables = [
        {
          key         = "execution_mode"
          value       = "remote"
          description = "Workspace based on Version Control."
        }
      ]
    }
  }
}
