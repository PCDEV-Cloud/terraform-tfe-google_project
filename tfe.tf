################################################################################
# Terraform Cloud - Project & Workspaces
################################################################################

module "tfe_project" {
  source = "github.com/PCDEV-Cloud/terraform-tfe-tfe_project?ref=v1.2.0"
  count  = var.tfe_config.enable ? 1 : 0

  organization = var.tfe_config.organization
  name         = var.name

  depends_on = [
    module.google_folders
  ]
}

module "tfe_workspace" {
  source   = "github.com/PCDEV-Cloud/terraform-tfe-tfe_workspace?ref=v1.2.0"
  for_each = toset(var.tfe_config.enable ? var.environments : [])

  organization                = var.tfe_config.organization
  project                     = module.tfe_project[0].name
  name                        = local.naming[each.value].google_project.project_id
  description                 = try(var.tfe_config.workspaces[each.value].description, "The ${upper(each.key)} environment of ${var.name} project.")
  execution_mode              = try(var.tfe_config.workspaces[each.value].execution_mode, "remote")
  apply_method                = try(var.tfe_config.workspaces[each.value].apply_method, "auto")
  terraform_version           = try(var.tfe_config.workspaces[each.value].terraform_version, "1.5.5")
  terraform_working_directory = try(var.tfe_config.workspaces[each.value].terraform_working_directory, local.naming[each.value].tfe_workspace.terraform_working_directory)
  tags                        = concat(local.naming[each.value].tfe_workspace.tags, try(var.tfe_config.workspaces[each.value].tags, []))
  ssh_key                     = try(var.tfe_config.workspaces[each.value].ssh_key, null)
  allow_destroy_plan          = try(var.tfe_config.workspaces[each.value].allow_destroy_plan, true)
  version_control             = try(var.tfe_config.workspaces[each.value].version_control, null)
  notifications               = try(var.tfe_config.workspaces[each.value].notifications, [])
  team_access                 = try(var.tfe_config.workspaces[each.value].team_access, [])

  variables = concat(
    [
      {
        key      = "environment"
        value    = lower(each.key)
        category = "terraform"
      },
      {
        key      = "project_id"
        value    = module.google_project[each.key].project_id
        category = "terraform"
      },
      {
        key      = "TFC_GCP_PROVIDER_AUTH"
        value    = true
        category = "env"
      },
      {
        key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
        value    = module.google_iam-tfe-oidc[each.key].apply_service_account_emails[0]
        category = "env"
      },
      {
        key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
        value    = module.google_iam-tfe-oidc[each.key].provider_names[0]
        category = "env"
      }
    ],
    try(var.tfe_config.workspaces[each.value].variables, [])
  )

  depends_on = [
    module.tfe_project
  ]
}
