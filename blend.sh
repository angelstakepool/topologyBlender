#!/bin/bash
source config

echo "Checking for $max_desired_peers peers"
echo "Finished product will be at $output_topology_path"

jq -s '.[0].Producers=([.[].Producers]|flatten)|.[0]' "${private_topology_path}" "${public_topology_path}"