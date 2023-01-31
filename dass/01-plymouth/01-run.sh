#!/bin/bash -e

install -d "${ROOTFS_DIR}/usr/share/plymouth/themes/dass"
install -m 644 files/themes/dass.plymouth "${ROOTFS_DIR}/usr/share/plymouth/themes/dass/"
install -m 644 files/themes/dass.script "${ROOTFS_DIR}/usr/share/plymouth/themes/dass/"
install -m 644 files/themes/dass.png "${ROOTFS_DIR}/usr/share/plymouth/themes/dass/"

on_chroot <<EOF
plymouth-set-default-theme dass
EOF
