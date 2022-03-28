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
}

variable "allow_account" {
  default = ""
  description = "Account ID to allow access to"
}