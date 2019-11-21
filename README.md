# A dockerized iSCSI targetd server

This consists in providing a docker image to run [Open iSCSI's targetd](https://github.com/open-iscsi/targetd).
It exposes an HTTP API to programmatically create LVM volume and export those over iSCSI.

This could be used in conjunction with [iSCSI-targetd provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/iscsi/targetd)
for kubernetes.

An helm chart for that provisioner is available [here](https://github.com/lionelnicolas/helm-iscsi-targetd-provisioner).

## Usage

### LVM setup

Before starting `targetd`, you'll need to create a dedicated LVM volume group.
LVM tools can be installed by doing:

```sh
# RHEL/CentOS/Fedora
yum install -y lvm2

# Debian/Ubuntu
apt install -y lvm2
```

Create a physical volume on device `/dev/sdX` and use it in a new volume group:

```sh
pvcreate /dev/sdX
vgcreate vg-targetd /dev/sdX
```

### Start targetd

You can now start `targetd`, using that new volume group as `TARGETD_POOLNAME`:

```sh
docker run \
	--detach \
	--name targetd \
	--restart=unless-stopped \
	--net host \
	--privileged \
	--volume /etc/target:/etc/target \
	--volume /run/lvm:/run/lvm \
	--volume /lib/modules:/lib/modules \
	--volume /sys/kernel/config:/sys/kernel/config \
	--volume /dev:/dev \
	--env TARGETD_GENERATE_CONFIG=true \
	--env TARGETD_USER=admin \
	--env TARGETD_PASSWORD=storagepass \
	--env TARGETD_POOLNAME=vg-targetd \
	lionelnicolas/targetd
```

### Configuration options

|          Variable         |                      Default                      |                 Description                |
|---------------------------|---------------------------------------------------|--------------------------------------------|
| `TARGETD_GENERATE_CONFIG` | `false`                                           | Generate config `/etc/target/targetd.yaml` |
| `TARGETD_USER`            | `admin`                                           | HTTP API username                          |
| `TARGETD_PASSWORD`        | `none`                                            | HTTP API password (required)               |
| `TARGETD_POOLNAME`        | `vg-targetd`                                      | LVM volume group                           |
| `TARGETD_TARGETNAME`      | `iqn.2003-01.org.linux-iscsi.${HOSTNAME}:targetd` | iSCSI qualified name to expose             |
| `TARGETD_SSL`             | `false`                                           | Enable HTTPS                               |
| `TARGETD_SSL_CERT`        | `/etc/target/targetd_cert.pem`                    | HTTPS SSL certificate                      |
| `TARGETD_SSL_KEY`         | `/etc/target/targetd_key.pem`                     | HTTPS SSL private key                      |
| `TARGETD_LOGLEVEL`        | `info`                                            | Targetd log level                          |

## Build

To rebuild that docker image:

```sh
docker build --tag lionelnicolas/targetd .
```

## License

This is licensed under the Apache License, Version 2.0. Please see [LICENSE](https://github.com/lionelnicolas/docker-targetd/blob/master/LICENSE)
for the full license text.

Copyright 2019 Lionel Nicolas
