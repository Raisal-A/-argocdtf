variable "repo_url" {
  description = "URL of the Git repository containing application manifests"
  type        = string
  default     = "your-repo-url"
}

variable "namespace" {
  description = "Namespace where the apps will be deployed"
  type        = string
  default     = "default"
}
