resource "triton_volume" "tritonnfs" {
  name     = var.name
  type     = "tritonnfs"
  size     = var.size
  networks = var.networks
  tags     = var.tags
}

output "volume_id" {
  value = triton_volume.tritonnfs.*.id
}

output "volume_fs_path" {
  value = triton_volume.tritonnfs.*.filesystem_path
}

output "volume_networks" {
  value = triton_volume.tritonnfs.*.networks
}

output "volume_state" {
  value = triton_volume.tritonnfs.*.state
}

output "volume_tags" {
  value = triton_volume.tritonnfs.*.tags
}

output "volume_type" {
  value = triton_volume.tritonnfs.*.type
}
