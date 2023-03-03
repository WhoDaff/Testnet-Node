#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://raw.githubusercontent.com/MOI14s/MOI14s_Nodes/main/MOI14s.sh | bash && sleep 1

# Set Vars
if [ ! $NODENAME ]; then
read -p "Your Node Name: " NODENAME
echo 'export NODENAME='\"${NODENAME}\" >> $HOME/.bash_profile
fi
echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
. $HOME/.bash_profile

#Update & Package
sleep 1
cd $HOME
sudo apt -q update
sudo apt -qy install gcc-12 build-essential
sudo apt -qy upgrade< "/dev/null"

#install GO
echo -e '\n\e[42mInstall Go\e[0m\n' && sleep 1
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.1.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
go version

#Clone Repository
echo -e '\n\e[42mInstall SAO\e[0m\n' && sleep 1
cd $HOME
git clone https://github.com/SaoNetwork/sao-consensus.git
cd sao-consensus
git checkout testnet0
make
which saod

#init
saod init sao-testnet --chain-id=sao-testnet0

#Download Config Files
cd $HOME/.sao/config
wget https://raw.githubusercontent.com/SAONetwork/sao-consensus/testnet0/network/testnet0/config/app.toml
wget https://raw.githubusercontent.com/SAONetwork/sao-consensus/testnet0/network/testnet0/config/client.toml
wget https://raw.githubusercontent.com/SAONetwork/sao-consensus/testnet0/network/testnet0/config/config.toml
wget https://raw.githubusercontent.com/SAONetwork/sao-consensus/testnet0/network/testnet0/config/genesis.json

#Start Service
saod start

echo -e '\n\e[42mSetUp Done\e[0m\n' && sleep 1
if [[ `service nibid status | grep active` =~ "running" ]]; then
  echo -e "Your Nibiru Node \e[32mInstalled and Works\e[39m!"
  echo -e "Check node status use command \e[7mservice $BINARY status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Nibiru Node \e[31mwas not installed correctly\e[39m, please reinstall."
fi