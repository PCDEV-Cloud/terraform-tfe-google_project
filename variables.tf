variable "name" {
  type        = string
  description = "Name of the project."
}

variable "environments" {
  type        = list(string)
  description = "List of project's environment. Each environment creates one Terraform Cloud Workspace and one Google Cloud Project."

  validation {
    condition     = alltrue([for i in var.environments : can(regex("^[a-zA-Z0-9]+$", i))])
    error_message = "Environments can only contain lowercase letters and numbers."
  }
}

variable "google_config" {
  type = object({
    parent                       = string
    randomize_project_id         = optional(bool, true)
    randomize_identity_pool_id   = optional(bool, true)
    randomize_provider_id        = optional(bool, true)
    randomize_service_account_id = optional(bool, true)
    billing_account              = optional(string, null)
    projects                     = optional(any, {})
  })
  description = "Custom configuration of Google Cloud Projects."
}

variable "tfe_config" {
  type = object({
    enable       = optional(bool, true)
    organization = optional(string)
    workspaces   = optional(any, {})
  })
  default     = {}
  description = "Custom configuration of Terraform Cloud Workspaces."

  validation {
    condition     = var.tfe_config.enable ? length(var.tfe_config.organization) > 0 : true
    error_message = "If config is enabled, the organization must be specified."
  }
}
