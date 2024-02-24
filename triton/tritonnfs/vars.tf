variable "name" {
}

variable "size" {
}

variable "networks" {
  type = list(any)
}

variable "tags" {
  type = map(any)
}
