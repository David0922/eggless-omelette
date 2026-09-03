#!/bin/bash

set -e -x

os="$(uname -s)"
if [[ "$os" != 'Linux' ]]; then
  echo "delete-bridge.sh only supports Linux, detected: $os"
  exit 1
fi

source load-env-var.sh

UPLINK_IF="$(ip route show default | awk '/default/ {print $5; exit}')"
UPLINK_IF6="$(ip -6 route show default | awk '/default/ {print $5; exit}')"

sudo iptables -t nat -D POSTROUTING -s "$BRIDGE_NET" -o "$UPLINK_IF" -j MASQUERADE 2>/dev/null || true
sudo iptables -D FORWARD -i "$BRIDGE" -o "$UPLINK_IF" -j ACCEPT 2>/dev/null || true
sudo iptables -D FORWARD -i "$UPLINK_IF" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

if [ -n "$UPLINK_IF6" ]; then
  sudo ip6tables -t nat -D POSTROUTING -s "$BRIDGE_NET6" -o "$UPLINK_IF6" -j MASQUERADE 2>/dev/null || true
  sudo ip6tables -D FORWARD -i "$BRIDGE" -o "$UPLINK_IF6" -j ACCEPT 2>/dev/null || true
  sudo ip6tables -D FORWARD -i "$UPLINK_IF6" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
fi

if ip link show "$BRIDGE" &>/dev/null; then
  sudo ip link set "$BRIDGE" down
  sudo ip link delete "$BRIDGE" type bridge
fi
