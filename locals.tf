locals {
  naming = { for i in var.environments : i => {
    google_project = {
      name       = title(join(" ", [var.name, i]))
      project_id = lower(replace(join("-", [var.name, i]), "/[\\s_]/", "-")) # Replace all upper letters to lower, inner spaces and underscores to hyphens.

      labels = {
        project     = lower(replace(var.name, "/\\s/", "-")) # Replace all upper letters to lower and inner spaces to hyphens.
        environment = lower(i)
      }
    }

    tfe_workspace = {
      terraform_working_directory = format("/terraform/google/projects/%s", lower(replace(var.name, "/[\\s]/", "-"))) # Replace all upper letters to lower and inner spaces to hyphens.
      tags                        = [for tag in ["google", i, var.name] : lower(replace(tag, "/\\s/", "-"))]          # Replace all upper letters to lower and inner spaces to hyphens.
    }
  } }
}
