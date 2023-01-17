#!/bin/bash

# Create namespaces
ip netns add foo
ip netns add bar

# Create veth interfaces and connect to namespaces
ip link add veth-foo type veth peer name veth-bar
ip link set veth-foo netns foo
ip link set veth-bar netns bar

# Set IP addreses
ip -n foo addr add 192.168.25.1/24 dev veth-foo
ip -n bar addr add 192.168.25.2/24 dev veth-bar

# Up veth interfaces
ip -n foo link set veth-foo up
ip -n bar link set veth-bar up

# Check connections between namespaces
ip netns exec foo arp
ip netns exec foo ping 192.168.25.2 -c 4
ip netns exec foo arp
ip -n bar link

# Connect namespaces through bridge(virtual net)
# Delete created interfaces
ip -n foo link del veth-foo

# Create linux bridge
ip link add bridge0 type bridge
ip link set dev bridge0 up

# Create new interfaces
ip link add veth-foo type veth peer name veth-foo-br0
ip link add veth-bar type veth peer name veth-bar-br0

# Connect interfaces to namespaces and bridge
ip link set veth-foo netns foo
ip link set veth-foo-br0 master bridge0
ip link set veth-bar netns bar
ip link set veth-bar-br0 master bridge0

# Set IP addresses
ip -n foo addr add 192.168.25.1/24 dev veth-foo
ip -n bar addr add 192.168.25.2/24 dev veth-bar

# Up veth interfaces
ip -n foo link set veth-foo up
ip -n bar link set veth-bar up

# Set IP addr to bridge and up interfaces
ip addr add 192.168.25.3/24 dev bridge0
ip link set veth-foo-br0 up
ip link set veth-bar-br0 up

# Check connections between namespaces
ip netns exec foo arp
ip netns exec foo ping 192.168.25.2 -c 4
ip netns exec foo arp
ip -n bar link

# Add route to outside via bridge
ip netns exec foo ip route add default via 192.168.25.3

# Set ip forwarding and source nat
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 192.168.25.0/24 -j MASQUERADE