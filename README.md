## STEP1  Customize your protocols and host them on your server


https://github.com/casper-network/docs/blob/dev/source/docs/casper/workflow/staging-files-for-new-network.md

https://docs.casperlabs.io/workflow/setup-private-network/

`accounts.toml`

```
[[accounts]]
public_key = "0152836c51eac04205bb7febe9d92da50758178b0bf388bd03e1da13147b99e2c5"

-> It is the public key in the path `/etc/casper/validator_keys` on validators' node.
note: `sudo -u casper casper-client keygen /etc/casper/validator_keys`

[[administrators]]
public_key = "0152836c51eac04205bb7febe9d92da50758178b0bf388bd03e1da13147b99e2c5"

-> It is the administrator's public key.
```

`chainspec.toml`

```
[protocol]
version = '1.0.0'
-> This matches protocol version
activation_point = '2022-07-12T12:05:00Z'
-> this is the time the network is to live.

[network]
name = 'mynetwork'
-> this is network name.

[core]
allow_unrestricted_transfers = false
compute_rewards = false
allow_auction_bids = false
refund_handling = { type = "refund", refund_ratio = [1, 1] }
fee_handling = { type = "accumulate" }
administrators = ["ADMIN_PUBLIC_KEY"]
-> https://docs.casperlabs.io/workflow/setup-private-network/

```

`config-example.toml`

```
[network]
known_addresses = ['16.162.124.124:35000','18.163.179.161:35000']
-> this is the genesis validators's ip address which must be online before network launching.
note `curl https://ipinfo.io/ip`
```

The file structure is like this 

```
└── mynetwork
    ├── 1_0_0
    │   ├── bin.tar.gz                -> source code of casper-node
    │   └── config.tar.gz             -> configuration files you have to customize. unzip -> customize -> zip
    ├── mynetwork.conf                -> the file to be copied in `Copy your conf to network_configs` of next step
    └── protocol_versions             -> version of your node. For new launch network, there is only 1 version.
```
*notes:*

*`mynetwork` is an example for network name, please replace with your network name.*

*`bin.tar.gz` and `config.tar.gz` are from https://github.com/casper-network/casper-node/releases/tag/private-1.4.6*

*mynetwork.conf*

```
SOURCE_URL= <your domain name of this server>
NETWORK_NAME=mynetwork
```

*protocol_versions*

```
1_0_0
```

### **You have to start your server before next step!**

Example for completed server: 

```
git clone https://github.com/Jiuhong-casperlabs/setup-mynode.git

cd setup-mynode

npm i

npm run start
```

### Check if the server starts successfully:

Issue this command 
```
curl -s http://<domain name>/<network name>/protocol_versions
```
for example, `curl -s http://testprivatenet.herokuapp.com/mynetwork/protocol_versions`

output should be
```
1_0_0
```

---
## STEP2 Install private network node

Clean up

```
sudo systemctl stop casper-node-launcher.service
sudo apt remove -y casper-client
sudo apt remove -y casper-node
sudo apt remove -y casper-node-launcher
sudo rm /etc/casper/casper-node-launcher-state.toml
sudo rm -rf /etc/casper/*
sudo rm -rf /var/lib/casper/*
```

Setup Casper Labs repo for packages

```
echo "deb https://repo.casperlabs.io/releases" bionic main | sudo tee -a /etc/apt/sources.list.d/casper.list
curl -O https://repo.casperlabs.io/casper-repo-pubkey.asc
sudo apt-key add casper-repo-pubkey.asc
sudo apt update
```

Install casper-node-launcher, casper-client, and jq

```
sudo apt install -y casper-client casper-node-launcher jq
```

Copy your conf to network_configs

Install all protocols 

For launching new network there should be only 1 protocol like 1_0_0

```
cd /etc/casper/network_configs
sudo -u casper curl -JLO mypn.herokuapp.com/mynetwork/mynetwork.conf
sudo -u casper /etc/casper/node_util.py stage_protocols mynetwork.conf
```


Validator Keys
If you do not have keys, you can create them

```
sudo -u casper casper-client keygen /etc/casper/validator_keys
```

Start the node

```
sudo /etc/casper/node_util.py rotate_logs
sudo /etc/casper/node_util.py start
```


refer to 
https://github.com/casper-network/casper-node/wiki/Mainnet-Node-Installation-Instructions

For upgrade see [upgrade](UPGRADE.md)