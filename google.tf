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
  source   = "github.com/PCDEV-Cloud/terraform-google-iam//modules/iam-tfe-oidc?ref=v1.0.0"
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
