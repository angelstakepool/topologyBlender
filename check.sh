#!/bin/bash

#Define some colors for the command line
WARN='\033[1;31m'
REKT='\033[1;31m'
SUCCESS='\033[0;32m'
INFO='\033[1;34m'
HELP='\033[1;36m'

NC='\033[0m'

blender_dir="$(dirname "$0")"

echo -e "${INFO}Check output topology Engaged!${NC}"


if [[ -f "$blender_dir/blender.config" ]]; then
  source "$blender_dir/blender.config"
else
  echo -e "${WARN}[FATAL ERROR]${NC} Could not find the blender.config file.\n Please see ${INFO}blender.example.config${NC} or run ${INFO}./setup.sh${NC} before continuing."
  exit
fi

if [[ ! -f "$output_topology_path" ]]; then
  echo -e "${WARN}[FATAL ERROR]${NC} Could not locate your output topology file.\n Please make sure it exists."
  exit
fi


echo -e "+===================================================================+"
echo -e "|  ${HELP}check${NC} by ${INFO}Adam Dean (modified by angel)${NC} | ${HELP}Crypto2099, Corp.${NC} | Pool: ${SUCCESS}BUFFY${NC}   |"
echo -e "+===================================================================+"

topology=$(jq . $output_topology_path)

cncli_path=$(command -v cncli)

if [[ -z "$cncli_path" ]]; then
  echo -e " ${REKT}CNCLI was not detected, cannot check topologies!${NC}"
  exit
else
  echo -e " ${INFO}CNCLI Detected!${NC}"
fi

output_topology=$(jq -c '.Producers[]' <<< $topology | while read i; do
    host=$(jq -r '.addr' <<< $i)
    port=$(jq -r '.port' <<< $i)
    j=$($cncli_path ping --host ${host} --port ${port})
    status=$(jq -r '.status' <<< $j)
    version=$(jq -r '.networkProtocolVersion' <<< $j)
    if [[ $status == 'ok' ]] && [[ $version == 9 ]]; then
      connectDuration=$(jq -r '.connectDurationMs' <<< $j)
      durationMs=$(jq -r '.durationMs' <<< $j)
      echo -e "   ${SUCCESS}Good Peer!${NC} Host: ${host} ConnectDurationMs: ${connectDuration} DurationMs: ${durationMs} ProtocolVersion: ${version}" 1>&2
      i=$(jq ". + {connectDurationMs: $connectDuration, durationMs: $durationMs}" <<< $i)
      echo $i
    else
      echo -e "   ${REKT}REKT Peer!${NC} Host: ${host} Port: ${port} Status: ${status} ProtocolVersion: ${version}" 1>&2
    fi
  done)
