#!/usr/bin/env bash

# Custom update script to update all my VMs and servers

SERVERS=("boblin.home" "roblin.home" "voblin.home")
VMS=("devbox.home" "firebox.home")
TIMEOUT=10

read -s -p "Enter server sudo password: " SUDO_PASSWORD
echo ""

for SERVER in "${SERVERS[@]}"; do
  echo "Connecting to ${SERVER}..."
  SERVER_HOSTNAME=$(echo ${SERVER} | cut -d '.' -f 1)

  ssh "${SERVER}" <<EOF
    if [ \$(nala list --upgradable | grep docker | wc -l) -ne 0 ]; then
      echo "Draining node ${SERVER}..."
      docker node update --availability drain ${SERVER_HOSTNAME}
      
      echo "Waiting for containers to stop..."
      while [ \$(docker ps | wc -l) -ne 1 ]; do print '.'; sleep 2; done
    fi

    echo "Running topgrade..."
    echo "${SUDO_PASSWORD}" | sudo -S ls > /dev/null
    /home/linuxbrew/.linuxbrew/bin/topgrade

    echo "Reactivating node ${SERVER}..."
    docker node update --availability active ${SERVER_HOSTNAME}
EOF

  echo "Completed session on ${SERVER}. Sleeping for ${TIMEOUT}s..."
  sleep "${TIMEOUT}"
done

for VM in "${VMS[@]}"; do
  echo "Connecting to ${VM}..."

  if [ "${VM}" == "firebox.home" ]; then
    read -s -p "Enter VM sudo password: " SUDO_PASSWORD
    echo ""
  fi

  ssh "${VM}" <<EOF
    echo "Running topgrade..."
    echo "${SUDO_PASSWORD}" | sudo -S ls > /dev/null
    /home/linuxbrew/.linuxbrew/bin/topgrade
EOF

  echo "Completed session on ${VM}"
done

echo "All sessions completed!"
