#!/bin/bash

BASE_DIR="/home/ethereum"
EXEC_DIR="${BASE_DIR}/execution"
CONS_DIR="${BASE_DIR}/consensus"
PRIMARY_NODE_IP=""

install_dependencies() {
    apt-get update
    apt-get install -y curl git openssl software-properties-common wget make python3-dev python3-venv binutils jq
}

copy_ethereum_dir() {
    cp -r ./ethereum /home/
}

prompt_for_ip() {
    local ip_address
    read -p "Please enter an IP address: " ip_address
    if [[ -z "$ip_address" ]]; then
        echo "Error: IP address cannot be empty."
    else
        PRIMARY_NODE_IP="$ip_address"
        echo "IP address saved: $PRIMARY_NODE_IP"
    fi
}

get_primary_enode() {
    mkdir -p "${EXEC_DIR}/datadir" 
    local primary_ip="$PRIMARY_NODE_IP"
    curl -X POST \
         -H "Content-Type: application/json" \
         --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' \
         "http://${primary_ip}:8545" | \
    jq .result.enode | \
    sed "s/127.0.0.1/${primary_ip}/" | \
    jq -s 'map(.)' > "${EXEC_DIR}/datadir/static-nodes.json"
}

setup() {
    install_dependencies
    copy_ethereum_dir
    prompt_for_ip
    get_primary_enode
}

setup
