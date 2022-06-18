variable "github_url" {
    description = "The URL of the GitHub OAuth2 provider"
    default     = "https://token.actions.githubusercontent.com"
    type        = string
}

variable "github_organization" {
    description = "The GitHub organization to allow access to"
    type        = string
}

variable "github_repositories" {
    description = "The GitHub repositories inside the organization you want to allow access to"
    default     = ["*"]
    type        = list(string)
}

variable "role_name" {
    description = "Name of the IAM role"
    default     = "GithubActionsRole"
    type        = string
}

variable "managed_policy_arns" {
    description = "The ARNs of the managed policies to attach to the role"
    default     = []
    type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  default     = {}
  type        = map(string)
}
