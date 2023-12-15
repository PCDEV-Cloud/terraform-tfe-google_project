variable "name" {
  type        = string
  description = ""

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9 _-]{1,28}[a-zA-Z0-9]$", var.name))
    error_message = "The name must be 3 to 30 characters in length. Can only contain letters, numbers, inner spaces hyphens (-) and underscores (_). Must start with a letter and end with a letter or number."
  }

  validation {
    condition     = !can(regex("^.*--.*$", var.name))
    error_message = "Hyphens cannot appear next to each other."
  }

  validation {
    condition     = !can(regex("^.*__.*$", var.name))
    error_message = "Underscores cannot appear next to each other."
  }
}

variable "randomize_name" {
  type        = bool
  default     = false
  description = "If true, adds a 6-digit random string preceded by a dash. The 'name' variable cannot then be longer than 23 characters."
}

variable "environments" {
  type        = list(string)
  description = ""

  # Only letters and numbers
}

variable "google_parent" {
  type        = string
  description = ""
}

variable "google_projects_config" {
  default     = null
  description = ""
}

variable "tfe_organization" {
  type        = string
  description = ""
}

variable "tfe_workspaces_config" {
  default     = null
  description = ""
}

variable "google_config" {
  type = object({
    parent   = string
    projects = optional(map(any), {})
  })
}

variable "tfe_config" {
  type = object({
    organization = string
    workspaces   = optional(map(any), {})
  })
}