resource "triton_vlan" "fabric_vlan" {
  vlan_id     = var.vlan_id
  name        = "${var.name}-VLAN"
  description = "Fabric VLAN for ${var.name} network"
}

resource "triton_fabric" "fabric_network" {
  vlan_id            = var.vlan_id
  name               = var.name
  description        = var.description
  subnet             = var.subnet
  provision_start_ip = var.provision_start_ip
  provision_end_ip   = var.provision_end_ip
  gateway            = var.gateway
  resolvers          = var.resolvers
  internet_nat       = var.internet_nat
  depends_on         = [triton_vlan.fabric_vlan]
}

