#!/bin/bash

install_dependencies() {
    apt-get update
    apt-get install -y curl git openssl software-properties-common wget make python3-dev python3-venv binutils
}

install_geth() {
	add-apt-repository -y ppa:ethereum/ethereum
	apt-get update 
	apt-get install -y ethereum
}

setup() {
    install_dependencies
    install_geth
}

setup

