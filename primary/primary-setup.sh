#!/bin/bash

BASE_DIR="/home/ethereum"
EXEC_DIR="${BASE_DIR}/execution"
CONS_DIR="${BASE_DIR}/consensus"

install_dependencies() {
    apt-get update
    apt-get install -y curl git openssl software-properties-common wget make python3-dev python3-venv binutils
}

install_geth() {
    add-apt-repository -y ppa:ethereum/ethereum
    apt-get update 
    apt-get install -y ethereum
}

copy_ethereum_dir() {
    cp -r ./ethereum /home/
}

init_geth() {
    geth init --datadir "$EXEC_DIR/datadir" "$EXEC_DIR/genesis.json"
}

setup() {
    install_dependencies
    install_geth
    copy_ethereum_dir
    init_geth
}

setup

