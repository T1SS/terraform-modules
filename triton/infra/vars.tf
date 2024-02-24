# For additional doc details please see main.tf

variable "image_name" {
  description = "Triton image name"
}

variable "image_version" {
  description = "Triton image version"
}

variable "package" {
  description = "Triton machine sizing package name"
}

variable "firewall" {
  default     = "true"
  description = "Triton firewall on/off switch"
}

variable "networks" {
  type        = list(string)
  description = "Triton network name or names"
}

variable "instances" {
  description = "Number of Triton instances"
}

variable "role" {
  description = "Application role name"
}

variable "user_script" {
  description = "Triton user script executed at boot time"
  sensitive   = true
}

variable "hostname" {
}

variable "account" {
  description = "Triton top level user account name"
}

variable "service_tags" {
  description = "TCNS service names"
}

variable "firewall_rules" {
  type = map(object({
    from        = string
    to          = string
    protocol    = string
    port        = number
    action      = string
    description = string
    enabled     = bool
  }))
  description = "Collection of Triton firewall rules for the instance"
}

variable "metadata" {
  type      = map(any)
  default   = null
  sensitive = true
}

variable "tags" {
  type    = map(any)
  default = null
}

variable "affinity_group" {
  default     = null
  description = <<EOT

                Special tag which can be used in a multi-node deploy job to generate
                a predictable tag with an incremented numerical suffix.
                Useful when other instances need to land on the same CNs
                as the multi-node instances but still spread on different CNs.

                EOT
}

variable "custom_affinity_rule" {
  type        = list(string)
  default     = null
  description = "Property for custom affinity rules. Supports the full Triton syntax."
}

variable "volumes" {
  type = map(object({
    name       = string
    mode       = string
    mountpoint = string
  }))
  default = null
}

variable "deletion_protection_enabled" {
  type        = bool
  default     = false
  description = <<EOT

                Additional instance deletion protection flag - if set to true,
                Triton protects this instance after creation even from Terraform itself.

                EOT
}
