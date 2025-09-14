#!/usr/bin/env bash

# Custom update script to update all my VMs and servers

SERVERS=("docker.home" "pi.home")
VMS=("devbox.home" "firebox.home")

read -s -p "Enter server sudo password: " SUDO_PASSWORD
echo ""

for server in "${SERVERS[@]}"; do
  echo "=== Connecting to ${server}... ===" && echo ""

  ssh "${server}" <<EOF
    echo "Running update..."
    echo "${SUDO_PASSWORD}" | sudo -S ls > /dev/null
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
EOF

  echo "=== Completed session on ${server} ===" && echo ""
done

for vm in "${VMS[@]}"; do
  echo "=== Connecting to ${vm}... ===" && echo ""

  if [ "${vm}" == "firebox.home" ]; then
    read -s -p "Enter VM sudo password: " SUDO_PASSWORD
    echo ""
  fi

  ssh "${vm}" <<EOF
    echo "Running topgrade..."
    echo "${SUDO_PASSWORD}" | sudo -S ls > /dev/null
    /home/linuxbrew/.linuxbrew/bin/topgrade
EOF

  echo "=== Completed session on ${vm} ===" && echo ""
done

echo ""
echo "All sessions completed!"
