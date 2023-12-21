variable "name" {
  type        = string
  description = ""
}

variable "environments" {
  type        = list(string)
  description = ""

  # Only letters and numbers
}

variable "google_config" {
  type = object({
    parent                       = string
    randomize_project_id         = optional(bool, true)
    randomize_identity_pool_id   = optional(bool, true)
    randomize_provider_id        = optional(bool, true)
    randomize_service_account_id = optional(bool, true)
    billing_account              = optional(string, null)
    projects                     = optional(map(any), {})
  })
  description = ""
}

variable "tfe_config" {
  type = object({
    organization = string
    workspaces   = optional(map(any), {})
  })
  description = ""
}
