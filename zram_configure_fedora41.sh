#!/bin/bash
set -e

echo "Disabling and removing any old disk-based swap..."
sudo swapoff -a
sudo rm -f /var/swap/swapfile
sudo sed -i '/swap/d' /etc/fstab

echo "Installing zram generator (if not installed)..."
sudo dnf install -y zram-generator
sudo dnf install -y zram-generator-defaults

echo "Creating custom zRAM config..."
sudo mkdir -p /etc/systemd/zram-generator.conf.d

cat <<EOF | sudo tee /etc/systemd/zram-generator.conf.d/custom.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
vm.swappiness = 30
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
EOF

echo "Reloading systemd and rebooting..."
sudo systemctl daemon-reexec
sudo reboot
