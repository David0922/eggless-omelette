#!/bin/bash

set -e -x

os="$(uname -s)"
if [[ "$os" != 'Linux' ]]; then
  echo "create-bridge.sh only supports linux, detected: $os"
  exit 1
fi

BRIDGE=devbox-br-0
BRIDGE_IP=10.0.2.1
BRIDGE_CIDR=24
BRIDGE_NET=10.0.2.0/24
UPLINK_IF="$(ip route show default | awk '/default/ {print $5; exit}')"

if ! ip link show "$BRIDGE" &>/dev/null; then
  sudo ip link add name "$BRIDGE" type bridge
  sudo ip addr add "$BRIDGE_IP/$BRIDGE_CIDR" dev "$BRIDGE"
  sudo ip link set "$BRIDGE" up
fi

sudo sysctl -w net.ipv4.ip_forward=1

if ! sudo iptables -t nat -C POSTROUTING -s "$BRIDGE_NET" -o "$UPLINK_IF" -j MASQUERADE 2>/dev/null; then
  sudo iptables -t nat -A POSTROUTING -s "$BRIDGE_NET" -o "$UPLINK_IF" -j MASQUERADE
fi

if ! sudo iptables -C FORWARD -i "$BRIDGE" -o "$UPLINK_IF" -j ACCEPT 2>/dev/null; then
  sudo iptables -A FORWARD -i "$BRIDGE" -o "$UPLINK_IF" -j ACCEPT
fi

if ! sudo iptables -C FORWARD -i "$UPLINK_IF" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; then
  sudo iptables -A FORWARD -i "$UPLINK_IF" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT
fi
