## Production grade Terraform modules for Triton Data Center

Terraform modules in this repo are considered production grade and have been extensively used to provision various instances on top of [Triton Data Center](https://github.com/TritonDataCenter/triton).

The following modules are supported:

```
triton/
|-- docker
|   |-- README.md
|   |-- main.tf
|   |-- vars.tf
|   `-- versions.tf
|-- fabric
|   |-- main.tf
|   |-- vars.tf
|   `-- versions.tf
|-- infra
|   |-- README.md
|   |-- main.tf
|   |-- vars.tf
|   `-- versions.tf
`-- tritonnfs
    |-- main.tf
    |-- vars.tf
    `-- versions.tf
```

### docker

Docker instances with extra Triton features.

### infra

For provisioning Bhyve VMs and bare-metal containers based on SmartOS or Linux.

### fabric

Software defined networks called fabrics (vxlan).

### tritonnfs

Machine independent NFS volumes mounted inside instances.


