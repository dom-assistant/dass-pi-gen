#!/bin/bash -e

install -d "${ROOTFS_DIR}/var/lib/domassistant"
install -m 755 files/dass-init.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 755 files/init-containers.sh "${ROOTFS_DIR}/var/lib/domassistant/"

on_chroot <<EOF
systemctl daemon-reload
systemctl enable dass-init.service
EOF
