## STEP1  Customize your protocols and host them on your server

### Required -> `chainspec.toml`

```
[protocol]
version = '1.0.1'
-> This matches protocol version
activation_point = 2
-> it represents an era ID, meaning the protocol version becomes active at the start of this era.
```


The file structure is like this 

```
└── mynetwork
    ├── 1_0_0
    │   ├── bin.tar.gz
    │   └── config.tar.gz
    ├── 1_0_1                -> new added
    │   ├── bin.tar.gz       -> new added
    │   └── config.tar.gz    -> new added
    ├── mynetwork.conf
    └── protocol_versions    -> change it adding new version of protocol

```
*notes:*

*protocol_versions*

```
1_0_0
1_0_1
```

### **You have to start your server before next step!**

### Check if the files are hosted successfully on your server:

Issue this command 
```
curl -s http://<domain name>/<network name>/protocol_versions
```
for example, `curl -s http://testprivatenet.herokuapp.com/mynetwork/protocol_versions`

output should be
```
1_0_0
1_0_1
```

---
## STEP2 Upgrade Casper node to new version 


```
sudo rm -rf /etc/casper/1_0_2
sudo rm -rf /var/lib/casper/bin/1_0_2
sudo -u casper /etc/casper/node_util.py stage_protocols mynetwork.conf
```
## Verifying Successful Staging

After you have successfully executed the above commands, wait a few minutes for a new block to be issued before checking that your node is correctly staged with the upgrade. After a few minutes, take a look at your status end-point, as follows:

`curl -s http://127.0.0.1:8888/status | jq .next_upgrade`

You should expect this output if properly staged, prior to upgrading:

```
$ curl -s localhost:8888/status | jq .next_upgrade
{
  "activation_point": 2,
  "protocol_version": "1.0.1"
}

```


refer to 
https://github.com/casper-network/casper-node/wiki/Upgrade-to-Casper-node-v1.4.6