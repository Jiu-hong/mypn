sudo /etc/casper/node_util.py stop
sudo apt remove -y casper-client
sudo apt remove -y casper-node
sudo apt remove -y casper-node-launcher
sudo rm /etc/casper/casper-node-launcher-state.toml
sudo rm -rf /etc/casper/1*
sudo rm -rf /etc/casper/2*
sudo rm -rf /var/lib/casper
sudo rm -rf /var/log/casper

sudo apt install -y casper-client casper-node-launcher casper-sidecar jq

# cd /etc/casper/network_configs
# sudo -u casper curl -JLO http://mynetwork.local:5000/mynetwork/mynetwork.conf
sudo curl -Lo /etc/casper/network_configs/mynetwork.conf http://mynetwork.local:5000/mynetwork/mynetwork.conf


sudo -u casper casper-node-util stage_protocols mynetwork.conf
sudo casper-node-util start
