data "triton_image" "image" {
  name    = var.image_name
  version = var.image_version
  # Want the most recent image in cases where
  # multiple images have the same version number.
  most_recent = true
}

# Data source for network UUID lookups.
# Translates network name to UUID.
data "triton_network" "network" {
  count = length(var.networks)
  name  = var.networks[count.index]
}

# Compute a unique firewall ID (tag) based on triton account name,
# machine role, image version and primary network name.
# This tag is also re-used for affinity rules.
locals {
  firewall_id = md5("${var.account}${var.role}${data.triton_image.image.version}${var.networks[0]}")
  tags        = var.tags == null ? { firewall_id = local.firewall_id } : merge(var.tags, { firewall_id = local.firewall_id })
}

# Firewall rule generation from variable "firewall_rules" which is of
# type map object and has the following structure.
# variable "firewall_rules" {
#   type = map(object({
#     from        = string
#     to          = string
#     protocol    = string
#     port        = number
#     action      = string
#     description = string
#     enabled     = bool
#   }))
# }
# Rules are managed by sdc-fwapi:
# https://github.com/TritonDataCenter/sdc-fwapi
resource "triton_firewall_rule" "ruleset" {
  for_each    = var.firewall_rules
  description = each.value.description
  rule        = replace("FROM ${each.value.from} TO ${each.value.to} ${each.value.action} ${each.value.protocol} PORT ${each.value.port}", "<FIREWALL_ID>", local.firewall_id)
  enabled     = each.value.enabled
}

resource "triton_machine" "infra" {
  # Generate a unique machine name - this is required to prevent name clashes in both Triton
  # and Consul.
  name  = "${var.hostname}${format("%02d", count.index + 1)}-${substr(uuid(), 0, 8)}"
  count = var.instances # number of instances to provision
  # Machine sizing package:
  # https://github.com/TritonDataCenter/sdc-papi
  package = var.package
  # Machine image same concept as Docker images:
  # https://github.com/TritonDataCenter/sdc-imgapi
  image            = data.triton_image.image.id
  firewall_enabled = var.firewall
  # User script executed on every boot, described at:
  # https://eng.tritondatacenter.com/mdata/datadict.html
  user_script = file(var.user_script)
  # configures one or more networks with splat expression
  networks = data.triton_network.network[*].id
  # strict affinity rule (operator '!=') to provision
  # each instance on different physical compute nodes.
  # Adheres to sdc-designation API rules:
  # https://github.com/TritonDataCenter/sdc-designation
  affinity = var.custom_affinity_rule != null ? var.custom_affinity_rule : ["firewall_id!=${local.firewall_id}"]

  # Unique tag used for both affinity and firewall rules
  # (computed above) matches group of instances in current
  # provisioning job.
  tags = var.affinity_group != null ? merge(local.tags, { affinity_group = "${var.affinity_group}${format("%02d", count.index + 1)}" }) : local.tags

  # Publish service name in DNS - CNS stands for:
  # Conatiner Name Service (also called TCNS - Triton Name Service)
  # https://github.com/TritonDataCenter/triton-cns/blob/master/docs/operator-guide.md
  cns {
    services = concat(var.service_tags, ["${var.hostname}${format("%02d", count.index + 1)}"])
  }

  # Metadata injection into the provisioned instance.
  # https://github.com/TritonDataCenter/mdata-client
  # Available inside the instance via:
  #   `mdata-get key-name`
  metadata = var.metadata

  # Type bool. If set to true, Triton protects the newly created instance
  # against accidental removal or Terraform destroy. Useful for core database
  # instances or other critical instances.
  deletion_protection_enabled = var.deletion_protection_enabled

  lifecycle {
    ignore_changes = [
      name
    ]
  }

  # available inside the instances via `mdata-get user-data`
  user_data = <<EOF
COUNT=${format("%02d", count.index + 1)}
EOF

  # persistent volumes which should be mounted for the instance
  dynamic "volume" {
    for_each = var.volumes == null ? {} : var.volumes
    content {
      name       = volume.value.name
      mountpoint = volume.value.mountpoint
      mode       = volume.value.mode
    }
  }
}

output "instance_name" {
  value = triton_machine.infra.*.name
}

output "primaryip" {
  value = triton_machine.infra.*.primaryip
}

output "compute_node" {
  value = triton_machine.infra.*.compute_node
}
