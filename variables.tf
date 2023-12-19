variable "name" {
  type        = string
  description = ""
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
