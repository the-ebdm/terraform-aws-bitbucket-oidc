variable "name" {
  type = string
}

variable "url" {
  type = string
}

variable "audiences" {
  type = list(string)
}

variable "iam_policy" {
  type = string
  default = "{\"Version\" : \"2012-10-17\",\"Statement\" : [{\"Sid\" : \"AdminPermissions\",\"Effect\" : \"Allow\",\"Action\" : [\"*\"],\"Resource\" : \"*\"}]}"
}

variable "allow_account" {
  default = ""
  description = "Account ID to allow access to"
}