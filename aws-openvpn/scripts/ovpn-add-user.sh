#!/bin/bash
#
# Shell script to create a user on the OpenVPN server.
#
#

set -e

BASEDIR=$(dirname $0)
BASENAME=$(basename $0)

# Variables
SSH_KEY=
SSH_PORT="222"
SSH_SERVER=
SSH_USERNAME=
VPN_USERNAME=

# Usage
function show_usage() {
  echo "Usage: ${BASENAME} [options]"
  echo "  options:"
  echo "    -i <FILE>      The SSH authentication key."
  echo "    -p <PORT>      The SSH server port (default value: 222)."
  echo "    -s <ADDRESS>   The SSH server address."
  echo "    -u <USERNAME>  The SSH username."
  echo "    -v <USERNAME>  The OpenVPN username."
}

# Options parsing
while getopts ":i:p:s:u:v:" opt; do
  case $opt in
    i)
      SSH_KEY=${OPTARG}
      ;;
    p)
      SSH_PORT=${OPTARG}
      ;;
    s)
      SSH_SERVER=${OPTARG}
      ;;
    u)
      SSH_USERNAME=${OPTARG}
      ;;
    v)
      VPN_USERNAME=${OPTARG}
      ;;
    \?)
      echo >&2 "  [ERROR] Invalid option: -${OPTARG}"
      exit 1
      ;;
    :)
      echo >&2 "  [ERROR] Option -${OPTARG} requires an argument"
      exit 2
      ;;
  esac
done

# Check arguments
if [[ $# -eq 0 ]]; then
  show_usage
  exit 3
fi

# Check requirements
if [[ "x${SSH_SERVER}" = "x" ]]; then
  echo >&2 "  [ERROR] The SSH server address (-s) option is mandatory."
  exit 4
fi
if [[ "x${VPN_USERNAME}" = "x" ]]; then
  echo >&2 "  [ERROR] The OpenVPN username (-v) option is mandatory."
  exit 5
fi

# Complement the username option
[[ ! "x${SSH_USERNAME}" == "x" ]] && SSH_USERNAME="${SSH_USERNAME}@"

# Complement the port option
[[ ! "x${SSH_PORT}" == "x" ]] && SSH_PORT="-p ${SSH_PORT}"

# Complement the key option
[[ ! "x${SSH_KEY}" == "x" ]] && SSH_KEY="-i ${SSH_KEY}"

# Execute the remote script
ssh ${SSH_KEY} \
  ${SSH_PORT} \
  ${SSH_USERNAME}${SSH_SERVER} \
  sudo ovpn_addclient -u "${VPN_USERNAME}"

# All done
exit 0
