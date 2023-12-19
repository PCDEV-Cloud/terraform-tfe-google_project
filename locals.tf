locals {
  naming = { for i in var.environments : i => {
    google_project = {
      name       = title(join(" ", [var.name, i]))
      project_id = lower(replace(join("-", [var.name, i]), "/[\\s_]/", "-")) # Replace all upper letters to lower, inner spaces and underscores to dashes.

      labels = {
        project     = lower(replace(var.name, "/\\s/", "-")) # Replace all upper letters to lower and inner spaces to dashes.
        environment = lower(i)
      }
    }

    tfe_workspace = {
      tags = [for tag in ["google", i, var.name] : lower(replace(tag, "/\\s/", "-"))] # Replace all upper letters to lower and inner spaces to dashes.
    }
  } }
}
