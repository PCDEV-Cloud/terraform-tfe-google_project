################################################################################
# Google Cloud - Folder & Projects
################################################################################

module "google_folders" {
  source = "github.com/PCDEV-Cloud/terraform-google-organization//modules/folders?ref=v1.2.0"

  parent  = var.google_config.parent
  folders = [{ display_name = var.name }]
}

module "google_project" {
  source   = "github.com/PCDEV-Cloud/terraform-google-organization//modules/project?ref=v1.2.0"
  for_each = toset(var.environments)

  name                     = local.naming[each.value].google_project.name
  project_id               = local.naming[each.value].google_project.project_id
  randomize_project_id     = var.google_config.randomize_project_id
  billing_account          = var.google_config.billing_account
  parent                   = module.google_folders.folders[0].name
  skip_delete              = try(var.google_config.projects[each.value].skip_delete, false)
  create_default_network   = try(var.google_config.projects[each.value].create_default_network, true)
  labels                   = merge(local.naming[each.value].google_project.labels, try(var.google_config.projects[each.value].labels, {}))
  enable_apis_and_services = true

  apis_and_services = concat([
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "sts.googleapis.com",
    "serviceusage.googleapis.com"
    ],
    try(var.google_config.projects[each.value].apis_and_services, [])
  )
}

################################################################################
# Google Cloud - OIDC Provider
################################################################################

resource "terraform_data" "google_project" {
  for_each = toset(var.environments)

  input = module.google_project[each.value].project_id

  provisioner "local-exec" {
    command = "sleep 30s" # TODO: move sleep value to variable
  }
}

module "google_iam-tfe-oidc" {
  source   = "github.com/PCDEV-Cloud/terraform-google-iam//modules/iam-tfe-oidc"
  for_each = toset(var.environments)

  project = terraform_data.google_project[each.value].output

  access_configuration = [
    {
      organization    = var.tfe_config.organization
      project         = var.name
      workspaces      = [local.naming[each.value].google_project.project_id]
      split_run_phase = false
    }
  ]

  randomize_identity_pool_id   = var.google_config.randomize_identity_pool_id
  randomize_provider_id        = var.google_config.randomize_provider_id
  randomize_service_account_id = var.google_config.randomize_service_account_id
}
<<<<<<< HEAD:google.tf
=======

################################################################################
# Terraform Cloud - Projects & Workspaces
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
  ]
}
>>>>>>> main:main.tf
