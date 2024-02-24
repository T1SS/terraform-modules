# shortid which will change on every TF run but stays the same
# for all instances within the same provisioning job.
# Required for instance name and hostname match.
locals {
  shortid = substr(uuid(), 0, 8)
  # docker labels which are modified in this module and are mandatory
  mod_labels = ["com.docker.swarm.affinities", "triton.cns.services"]
}

resource "docker_container" "instance" {
  name       = "${var.hostname}${format("%02d", count.index + 1)}-${substr(uuidv5("dns", "${var.hostname}${format("%02d", count.index + 1)}${local.shortid}"), 0, 8)}"
  hostname   = "${var.hostname}${format("%02d", count.index + 1)}-${substr(uuidv5("dns", "${var.hostname}${format("%02d", count.index + 1)}${local.shortid}"), 0, 8)}"
  image      = docker_image.myimage.image_id
  count      = var.instances # number of instances to provision
  must_run   = true
  restart    = "always"
  entrypoint = var.entrypoint # helper script to execute
  command    = var.command
  log_driver = var.log_driver
  log_opts   = var.log_opts

  # Custom /etc/hosts entries, default is null, which means optional and not
  # required. If decalred (not null) template it and add to /etc/hosts.
  dynamic "host" {
    for_each = var.hosts == null ? {} : var.hosts

    content {
      host = host.value.hostname
      ip   = host.value.ip_address
    }
  }

  # On Triton Docker instance sizing, affinity, network configuration
  # and DNS (CNS) service discovery is configured with the labels below.
  # Check for triton.cns.services label as we also want to add the "friendly"
  # hostname to it for cases where each instance needs a service record
  # without the random shortid part.
  dynamic "labels" {
    for_each = [for l in var.labels : {
      label = l.label
      value = l.value
      } if !contains(local.mod_labels, l.label)
    ]

    content {
      label = labels.value.label
      value = labels.value.value
    }
  }

  # labels below (non dynamic) are workarounds for label generation with the count variable
  labels {
    label = "com.docker.swarm.affinities"
    value = var.affinity_group != null ? "[\"affinity_group==${var.affinity_group}${format("%02d", count.index + 1)}\"]" : var.labels.com_docker_swarm_affinities.value
  }

  labels {
    label = "triton.cns.services"
    value = join(",", [var.labels.triton_cns_services.value, "${var.hostname}${format("%02d", count.index + 1)}"])
  }

  # ENV variables exposed to processes inside
  env = setunion(["COUNT=${format("%02d", count.index + 1)}", "FHOSTNAME=${var.hostname}${format("%02d", count.index + 1)}"], var.env)

  # Triton runs a dedicated TCP/IP stack (crossbow) per conatiner,
  # for that reason there is no need nor desire for port translation.
  # i.e. internal and external port is always the same (and must be the same).
  dynamic "ports" {
    for_each = var.ports

    content {
      internal = ports.key
      external = ports.key
    }
  }

  # Support for one or more file upload via upload_files map object.
  #  variable "upload_files" {
  #  type = map(object({
  #    local_file  = string
  #    remote_file = string
  #    executable  = bool
  #  }))
  #  }
  dynamic "upload" {
    for_each = var.upload_files == null ? {} : var.upload_files

    content {
      content    = upload.value.local_file
      file       = upload.value.remote_file
      executable = upload.value.executable
    }
  }

  # ignore attributes which are automatically computed by Triton itself
  lifecycle {
    ignore_changes = [name, hostname, cpu_shares, memory_swap, memory, dns, dns_search, domainname, network_mode]
  }
}

data "docker_registry_image" "myimage" {
  name = var.image
}

resource "docker_image" "myimage" {
  # If an explicit docker_sha256 sum is defined, use that instead of docker_tag.
  # This is useful for cases where strict image versions are required and we don't
  # want to or cannot rely on tags only - as tags can be re-tagged against different
  # sha256 sums which could then result in a very different version of the image.
  name          = var.docker_sha256 == null ? "${data.docker_registry_image.myimage.name}:${var.docker_tag}" : "${data.docker_registry_image.myimage.name}@${var.docker_sha256}"
  keep_locally  = true
  pull_triggers = ["data.docker_registry_image.myimage.sha256_digest"]
}

# output variables - these are used for information only
output "instance_name" {
  value = docker_container.instance.*.name
}

output "image" {
  value = docker_image.myimage.repo_digest
}
