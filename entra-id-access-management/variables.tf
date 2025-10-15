variable "tenant_domain" {
  description = "Your Azure Entra ID tenant domain"
  type        = string
}

variable "user_password" {
  description = "Initial password for test user"
  type        = string
  sensitive   = true
}