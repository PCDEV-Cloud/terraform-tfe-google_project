output "tfe_workspace_tags" {
  value = { for key, workspace in module.tfe_workspace : key => workspace.tags }
}

output "tfe_workspace_terraform_version" {
  value = { for key, workspace in module.tfe_workspace : key => workspace.terraform_version }
}
