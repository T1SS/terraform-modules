terraform {
  required_version = ">= 1.2"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.25.0"
    }
  }
}
