# Freddy's Ubuntu Vagrant

A Freddy personalised Ubuntu virtual machine, provisioned using Vagrant.

## Getting Started

### Prerequistes

In addition to Vagrant, Virtual Box is required to be installed.

### Deployment

```
vagrant up
```

## Retaining the persistent disk

The secondary disk file *secondary_disk.vdi* is mounted to the */persistent* directory on the guest machine.
This disk can be copied and renamed prior to vagrant destruction to retain it's data.

Example:

```
cp secondary_disk.vdi bak.secondary_disk.vdi
vagrant destroy
```

It can be restored in a fresh vagrant stand up by renaming the disk file back to *secondary_disk.vdi*.

Example:

```
mv bak.secondary_disk.vdi secondary_disk.vdi
vagrant up
```
