sudo curl -JLo /etc/casper/network_configs/mynetwork.conf http://mynetwork.local:5000/mynetwork/mynetwork.conf
sudo -u casper casper-node-util stage_protocols mynetwork.conf
