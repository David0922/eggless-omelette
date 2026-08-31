#!/bin/bash

set -e -x

os="$(uname -s)"
if [[ "$os" != 'Linux' ]]; then
  echo "delete-bridge.sh only supports Linux, detected: $os"
  exit 1
fi

BRIDGE=devbox-br-0
BRIDGE_NET=10.0.2.0/24
UPLINK_IF="$(ip route show default | awk '/default/ {print $5; exit}')"

sudo iptables -t nat -D POSTROUTING -s "$BRIDGE_NET" -o "$UPLINK_IF" -j MASQUERADE 2>/dev/null || true
sudo iptables -D FORWARD -i "$BRIDGE" -o "$UPLINK_IF" -j ACCEPT 2>/dev/null || true
sudo iptables -D FORWARD -i "$UPLINK_IF" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

if ip link show "$BRIDGE" &>/dev/null; then
  sudo ip link set "$BRIDGE" down
  sudo ip link delete "$BRIDGE" type bridge
fi
