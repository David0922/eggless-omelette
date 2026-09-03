#!/bin/bash

set -e -x

os="$(uname -s)"
if [[ "$os" != 'Linux' ]]; then
  echo "create-bridge.sh only supports linux, detected: $os"
  exit 1
fi

source load-env-var.sh

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

if [ "$ENABLE_IPV6" = true ]; then
  UPLINK_IF6="$(ip -6 route show default | awk '/default/ {print $5; exit}')"
  if [ -z "$UPLINK_IF6" ]; then
    echo 'ENABLE_IPV6 is true but the host has no IPv6 default route; cannot determine uplink interface for NAT66'
    exit 1
  fi

  if ! ip -6 addr show dev "$BRIDGE" | grep -q "$BRIDGE_IP6/$BRIDGE_CIDR6"; then
    sudo ip -6 addr add "$BRIDGE_IP6/$BRIDGE_CIDR6" dev "$BRIDGE"
  fi

  sudo sysctl -w net.ipv6.conf.all.forwarding=1

  if ! sudo ip6tables -t nat -C POSTROUTING -s "$BRIDGE_NET6" -o "$UPLINK_IF6" -j MASQUERADE 2>/dev/null; then
    sudo ip6tables -t nat -A POSTROUTING -s "$BRIDGE_NET6" -o "$UPLINK_IF6" -j MASQUERADE
  fi

  if ! sudo ip6tables -C FORWARD -i "$BRIDGE" -o "$UPLINK_IF6" -j ACCEPT 2>/dev/null; then
    sudo ip6tables -A FORWARD -i "$BRIDGE" -o "$UPLINK_IF6" -j ACCEPT
  fi

  if ! sudo ip6tables -C FORWARD -i "$UPLINK_IF6" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; then
    sudo ip6tables -A FORWARD -i "$UPLINK_IF6" -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT
  fi
fi
