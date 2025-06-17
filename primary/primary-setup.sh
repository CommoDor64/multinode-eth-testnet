#!/bin/bash

install_dependencies() {
    apt-get update
}

copy_ethereum_dir() {
    cp -r ./ethereum /home/
}

setup() {
    install_dependencies
    copy_ethereum_dir
}

setup

