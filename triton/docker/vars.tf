variable "hostname" {
}

variable "instances" {
  description = "Number of Triton instances"
}

variable "ports" {
  type        = set(string)
  description = "Networks ports to expose and allow on firewall"
}

variable "command" {
  type        = list(string)
  description = "Docker command pass to entrypoint as $@"
}

variable "entrypoint" {
  type        = list(string)
  description = "Docker entrypoint executable"
}

variable "image" {
  description = "Docker image"
}

variable "env" {
  type        = set(string)
  description = "ENV variables, visible to processes inside Docker"
  sensitive   = true
}

variable "upload_files" {
  type = map(object({
    local_file  = string
    remote_file = string
    executable  = bool
  }))
}

variable "labels" {
  description = "Docker labels"
  type = map(object({
    label = string
    value = string
  }))
}

variable "log_driver" {
  default = null
}

variable "log_opts" {
  default = null
  type    = map(any)
}

variable "affinity_group" {
  default = null
}

variable "hosts" {
  default     = null
  description = "Custom /etc/hosts file entries"
  type = map(object({
    hostname   = string
    ip_address = string
  }))
}

variable "docker_sha256" {
  default = null
}

variable "docker_tag" {
  default = "latest"
}
