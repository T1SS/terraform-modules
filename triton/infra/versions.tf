terraform {
  required_version = ">= 1.2"
  required_providers {
    triton = {
      source  = "joyent/triton"
      version = "0.8.2"
    }
  }
}
