
variable "credentials" {
    type    = list(any)
}

variable "location" {
    description = "Region for the Google Cloud Platform"
    type        = string
}

variable "zone" {
    description = "Zone for the Google Cloud Platform Region"
    type        = string
    default     = "a"
}

variable "root_domain" {
    description = "root domain for everything"
    type        = string
    default     = "masterthesis.online"
}

variable "project_id" {
    description = "ID of the Google Cloud Project"
    type        = string
}

variable "credential_file_name" {
  description   = "the name of the json file with the credentials for the project, should be locatet in the root module"
  type          = string
}

variable "email" {
  description   = "email address used for letsencrypt"
  type          = string
}

variable "account_id" {
  description   = "the gcp iam account name"
  type          = string
}