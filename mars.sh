#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export MARS_CHAIN_ID=ares-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.19.4"
  cd $HOME
wget -O go1.19.4.linux-amd64.tar.gz https://golang.org/dl/go1.19.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz && sudo rm go1.19.4.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
fi

# download binary
cd $HOME
rm -rf hub
git clone https://github.com/mars-protocol/hub
cd hub
git checkout v1.0.0-rc7
make install

# config
marsd config chain-id $MARS_CHAIN_ID
marsd config keyring-backend test

# init
marsd init $NODENAME --chain-id $MARS_CHAIN_ID

# download genesis and addrbook
curl -s https://raw.githubusercontent.com/dylanschultzie/networks-3/main/ares-1/genesis.json > $HOME/.mars/config/genesis.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0umars\"/" $HOME/.mars/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@mars-testnet.nodejumper.io:30656,cebe0a3be105df1c5682bfcb9692b43bed8b4378@178.208.252.54:28656,648d3e69a428485fbd3bf221a9292d895ea656f0@159.69.5.164:15656,1a026f66b85594cf1d842c6f00f665f6d8baddf2@65.108.126.35:33656,9a191e8b191d1c8e36176b508b9f71f31677f9f8@15.204.207.117:26656,4a5f182aba299adf96b81901b0b0d55ab486037e@168.119.124.130:58656,fe8d614aa5899a97c11d0601ef50c3e7ce17d57b@65.108.233.109:18556,2d979fe8e9943ff8d6be2bfd1df87b89ec5a99cd@195.201.197.4:22656,6fce5a4698bd88724e6c84e5e737828e221a4ebb@51.81.57.80:10556,4f23560a080541248db96a0a83dd37ffe0beedaf@65.109.85.226:7240,75fd0645d505069d293e0fe15170d46e3b8ad5df@173.212.247.6:26656,7ed60b9fdfc250a7a10bba3c539bce58c9533b5a@65.108.11.180:23656,e93d1a4f097600539d0e5f2f04adbbe418517107@178.63.8.245:60856,14ff7bc373e6ffc6978afa3c83c811638a8553a6@85.239.243.210:26656,df5d4e6662b0b3f716c9a9adc213c68456caeff6@65.108.3.234:33656,d86ae4821902a61570323c3940fb56851ff2ebda@88.99.3.158:11456,13d97afdbc6150467f7ed3eff40860d82b3ec8ad@38.242.253.207:26656,0d03b322852add71896c6bbf0010e68410b45ac3@37.187.144.187:32656,9cb80d19455f755d803a0c4cec3b4bc7e88d36c7@92.204.132.53:26656,d2ea30dd1dc0fcf7ca0c4f4bb8bc1b9f07bd6b05@65.109.19.93:27312,3179d6c8897bbe6cbc8be327faa0b5943b4c066d@65.109.85.221:7240,1f2628d8da99dafc22653bbc74440a2bfd5397c1@38.242.142.118:26656,44f2ce33780b591a046bfaff0a35f0332c44d1b8@95.217.35.186:60756,8987b47ff9e681299e26e609373bf096cce413e0@185.190.140.105:20656,2ee054ce1acd24950c4da97d2d5109152afe400f@91.144.158.116:60556,482b1509c492e075ae9b507d38a5ff710e5a598f@209.182.238.30:26656,6f7deb4f24f6fe5d450433bca91a327ac38d8d2f@85.239.249.32:45656,d387afb4fb00f6c16e6adaee596cf2f75b328146@136.243.88.91:7240,8d56c709c724b05d80fad790744f4b2255ffe90d@135.181.16.252:34656,e17a62b746f6dc3a19a49887ba484306859c4beb@206.246.71.251:45656,b0b0ae6d6ff4ca64de8281371f729796ac4ec5f6@23.88.70.109:33656,c44a3efce778007efad9bb72772ecd38ff449f45@178.18.242.35:20656,61699a47c1b540d2581edb40e65627cdb50e6019@65.108.140.220:28656,db01c56a1cf6d6c9fd8e90bbbb5807e39e186b02@85.239.234.222:20656,08076453488caf03c5d391edcc124b31c558ad23@65.109.85.225:7240,76226517bd06932c9e0957bd4dd7b995227cdaa4@95.216.242.177:33656,3b2c8bc6a1dba482f6d85e19f78355a9f64950e2@65.109.88.254:32656,adc3f9a1af20dd3439c48548016b7716deac87f9@65.109.93.115:30656,9e6eac82887f7422bc49651f8ffda6bfd2848f53@74.208.244.144:20656,d12988a6f4cd9ee49d63f3f2b50facf23bbbec13@199.175.98.112:28656,1eb8f66ad73bfaad455fa3c9711029a723367642@65.108.67.152:45656,44bf92585ab06772e8822d28ef04595888eaa427@65.21.199.148:26631,2bdb587f6202165f3c66b730e437afe00c8de171@194.163.132.91:26656,f28e4984599feefc0490014713cee04c741c711c@65.108.134.215:35656,4e6467322dc065917bccab4784041d32a4c1e27a@34.170.137.53:20656,7342199e80976b052d8506cc5a56d1f9a1cbb486@65.21.89.54:26653,b8b7acfa93a6812843d769e8a5eebb83d82f3d62@207.244.245.41:26656,c09e47ad29ea0421bc9cf073c4e104530f56a7ed@38.129.16.21:12,e5577ecbf793ce92ce5993c4841a340a4c9db64b@65.108.204.119:46656,ffa2af828149e2743095b4bcb902b09f5ccd055a@185.177.116.160:20656,1fabbd6ebca5b58715e8225af1560ca2e8172d47@80.254.8.54:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.mars/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.mars/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.mars/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.mars/config/config.toml

# create service
sudo tee /etc/systemd/system/marsd.service > /dev/null << EOF
[Unit]
Description=Mars Service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which marsd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

marsd tendermint unsafe-reset-all

# start service
sudo systemctl daemon-reload
sudo systemctl enable marsd
sudo systemctl start marsd

break
;;

"Create Wallet")
marsd keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
MARS_WALLET_ADDRESS=$(marsd keys show $WALLET -a)
MARS_VALOPER_ADDRESS=$(marsd keys show $WALLET --bech val -a)
echo 'export MARS_WALLET_ADDRESS='${MARS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MARS_VALOPER_ADDRESS='${MARS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
marsd tx staking create-validator \
  --amount 1000000umars \
  --from wallet \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(marsd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id ares-1 \
  -y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
