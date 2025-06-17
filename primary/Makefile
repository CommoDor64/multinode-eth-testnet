BASE_DIR := /home/ethereum
EXEC_DIR := $(BASE_DIR)/execution
VAL_DIR := $(BASE_DIR)/validator
CONS_DIR := $(BASE_DIR)/consensus
MNEMONIC := "twenty remain wing vast coast advance impose fashion chimney know eagle random earth helmet almost inspire replace practice goddess fever trick detect speed cream"

install_dependencies:
	apt-get update
	apt-get install -y curl git openssl software-properties-common wget make python3-dev python3-venv binutils

init_directories: install_dependencies
	mkdir -p $(EXEC_DIR) $(VAL_DIR) $(CONS_DIR)
	openssl rand -base64 32 > $(EXEC_DIR)/password.txt
	openssl rand -base64 32 > $(VAL_DIR)/password.txt
	openssl rand -base64 32 > $(CONS_DIR)/password.txt

build_staking_deposit: init_directories
	git clone https://github.com/CommoDor64/staking-deposit-cli.git $(BASE_DIR)/staking-deposit-cli
	make -C $(BASE_DIR)/staking-deposit-cli clean
	make -C $(BASE_DIR)/staking-deposit-cli build_linux
	chmod +x $(BASE_DIR)/staking-deposit-cli/dist/deposit

install_geth: build_staking_deposit
	add-apt-repository -y ppa:ethereum/ethereum
	apt-get update
	apt-get install -y ethereum
	wget https://gist.githubusercontent.com/CommoDor64/739aa585bbb17048985fb8ff1f3aa9c3/raw/genesis.json -P $(EXEC_DIR)

install_prysm: install_geth
	wget https://github.com/OffchainLabs/prysm/releases/download/v6.0.4/beacon-chain-v6.0.4-linux-amd64 -O /tmp/beacon-chain
	chmod +x /tmp/beacon-chain
	mv /tmp/beacon-chain /usr/local/bin/beacon-chain
	wget https://github.com/OffchainLabs/prysm/releases/download/v6.0.4/prysmctl-v6.0.4-linux-amd64 -O /tmp/prysmctl
	chmod +x /tmp/prysmctl
	mv /tmp/prysmctl /usr/local/bin/prysmctl
	wget https://github.com/OffchainLabs/prysm/releases/download/v6.0.4/validator-v6.0.4-linux-amd64 -O /tmp/validator
	chmod +x /tmp/validator
	mv /tmp/validator /usr/local/bin/validator

get_config: install_prysm
	wget https://gist.githubusercontent.com/CommoDor64/9fa57c5b8ae303494743bcff08feb3cf/raw/config.yml -P $(CONS_DIR)

generate_jwt: get_config
	beacon-chain generate-auth-secret --output-file $(BASE_DIR)/jwtsecret

generate_validator_keys: generate_jwt
	$(BASE_DIR)/staking-deposit-cli/dist/deposit --language english --non_interactive existing-mnemonic --mnemonic $(MNEMONIC) --num_validators 64 --validator_start_index 0 --chain testnet --keystore_password "$(shell cat $(VAL_DIR)/password.txt)" --folder $(VAL_DIR)

import_account: generate_validator_keys
	validator accounts import --keys-dir=$(VAL_DIR)/validator_keys/ --wallet-dir=$(VAL_DIR)/validator_wallet --account-password-file=$(VAL_DIR)/password.txt --wallet-password-file=$(VAL_DIR)/password.txt --accept-terms-of-use

generate_genesis: import_account
	prysmctl testnet generate-genesis --fork electra --genesis-time-delay 120 --num-validators 64 --chain-config-file $(CONS_DIR)/config.yml --geth-genesis-json-in $(EXEC_DIR)/genesis.json --geth-genesis-json-out $(EXEC_DIR)/genesis.json --output-ssz $(CONS_DIR)/genesis.ssz --deposit-json-file $(VAL_DIR)/validator_keys/deposit_data-*.json

init_geth: generate_genesis
	geth init --datadir $(EXEC_DIR)/datadir $(EXEC_DIR)/genesis.json

setup: init_geth

start_geth:
        geth --http --http.api eth,net,web3,engine --authrpc.jwtsecret=$(BASE_DIR)/jwtsecret --datadir $(EXEC_DIR)/datadir --nodiscover --syncmode full --allow-insecure-unlock --password $(EXEC_DIR)/password.txt &

start_beacon_chain:
        beacon-chain --datadir="$(CONS_DIR)/datadir" --execution-endpoint=http://localhost:8551 --jwt-secret="$(BASE_DIR)/jwtsecret" --genesis-state="$(CONS_DIR)/genesis.ssz" --chain-config-file="$(CONS_DIR)/config.yml" --min-sync-peers=0 --bootstrap-node= --rpc-host 0.0.0.0 --http-host 0.0.0.0 --accept-terms-of-use &

start_validator:
        validator --datadir="$(VAL_DIR)/datadir" --beacon-rpc-provider=127.0.0.1:4000 --chain-config-file="$(CONS_DIR)/config.yml" --accept-terms-of-use --wallet-dir="$(VAL_DIR)/validator_wallet/" --wallet-password-file="$(VAL_DIR)/password.txt"
