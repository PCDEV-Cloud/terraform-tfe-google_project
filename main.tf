resource "random_string" "suffix" {
  count = var.randomize_name ? 1 : 0

  length  = 6
  numeric = true
  lower   = false
  upper   = false
  special = false
}

################################################################################
# Google Cloud - Folders & Projects
################################################################################

module "google_folders" {
  source = "github.com/PCDEV-Cloud/terraform-google-organization//modules/folders"

  parent  = var.google_config.parent
  folders = [{ display_name = var.name }]
}

module "google_project" {
  source   = "github.com/PCDEV-Cloud/terraform-google-organization//modules/project"
  for_each = toset(var.environments)

  name                 = local.naming[each.value].google_project.name
  project_id           = local.naming[each.value].google_project.project_id
  randomize_project_id = false
  parent               = module.google_folders.folders[0].name
  # billing_account        = try(var.google_projects_config[each.value].billing_account, null)
  # skip_delete            = try(var.google_projects_config[each.value].skip_delete, false)
  # create_default_network = try(var.google_projects_config[each.value].create_default_network, true)
  billing_account        = try(var.google_config.projects[each.value].billing_account, null)
  skip_delete            = try(var.google_config.projects[each.value].skip_delete, false)
  create_default_network = try(var.google_config.projects[each.value].create_default_network, true)
  labels                 = merge(local.naming[each.value].google_project.labels, try(var.google_config.projects[each.value].labels, {}))

  depends_on = [
    module.google_folders
  ]
}

module "google_iam-tfe-oidc" {
  source   = "github.com/PCDEV-Cloud/terraform-google-iam//modules/iam-tfe-oidc"
  for_each = toset(var.environments)

  project = module.google_project[each.value].project_id

  access_configuration = [
    {
      organization    = var.tfe_config.organization
      project         = var.name
      workspaces      = [module.google_project[each.value].project_id]
      split_run_phase = false
    }
  ]

  depends_on = [
    module.google_project
  ]
}

################################################################################
# Terraform Cloud - Projects & Workspaces
################################################################################

module "tfe_project" {
  source = "github.com/PCDEV-Cloud/terraform-tfe-tfe_project"

  organization = var.tfe_config.organization
  name         = var.name
}

module "tfe_workspace" {
  source   = "github.com/PCDEV-Cloud/terraform-tfe-tfe_workspace"
  for_each = toset(var.environments)

  organization                = var.tfe_config.organization
  project                     = module.tfe_project.name
  name                        = module.google_project[each.key].project_id
  description                 = try(var.tfe_config.workspaces[each.value].description, "The ${upper(each.key)} environment of ${var.name} project.")
  execution_mode              = try(var.tfe_config.workspaces[each.value].execution_mode, "remote")
  apply_method                = try(var.tfe_config.workspaces[each.value].apply_method, "auto")
  terraform_version           = try(var.tfe_config.workspaces[each.value].terraform_version, "1.5.5")
  terraform_working_directory = try(var.tfe_config.workspaces[each.value].terraform_working_directory, "/terraform")
  tags                        = concat(local.naming[each.value].tfe_workspace.tags, try(var.tfe_config.workspaces[each.value].tags, []))

  # version_control = {
  #   name                        = "GitHub"
  #   repository                  = "my-github/my-repository"
  #   branch                      = "main"
  #   include_submodules          = true
  #   automatic_speculative_plans = true

  #   triggers = {
  #     type  = "path_patterns"
  #     paths = ["terraform/**/*"]
  #   }
  # }

  variables = [
    {
      key      = "environment"
      value    = lower(each.key)
      category = "terraform"
    },
    {
      key      = "google_project"
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
  ]

  depends_on = [
    module.google_project,
    module.tfe_project
  ]
}
