# !/bin/bash
# This is to run casper-node using supervisor instead of systemd.
NODE_ROOT=${CASPER_NODE_ROOT:-/home/jh/mynetwork-node}

# stop casper-node-launcher if it is running
sudo supervisorctl stop casper-node-launcher

# remove casper software and jq if they exist, and remove etc, bin, database, logs folders under /home/jh/mynetwork-node if they exist
sudo apt remove -y casper-client
sudo apt remove -y casper-node
sudo apt remove -y casper-node-launcher
sudo rm -rf $NODE_ROOT/etc
sudo rm -rf $NODE_ROOT/database
sudo rm -rf $NODE_ROOT/bin
sudo rm -rf $NODE_ROOT/logs

# install casper software and jq
sudo apt install -y casper-client casper-node-launcher casper-sidecar jq

# create etc, bin, database,logs folders under /home/jh/mynetwork-node
mkdir -p $NODE_ROOT/etc/network_configs
mkdir -p $NODE_ROOT/validator_keys
if [ -z "$(ls -A $NODE_ROOT/validator_keys)" ]; then
    casper-client keygen $NODE_ROOT/validator_keys
fi
mkdir -p $NODE_ROOT/database
mkdir -p $NODE_ROOT/bin
mkdir -p $NODE_ROOT/logs

# stage protocols
sudo curl -JLo $NODE_ROOT/etc/network_configs/mynetwork.conf http://mynetwork.local:5000/mynetwork/mynetwork.conf
my-node-util stage_protocols mynetwork.conf

# copy supervisord.conf if not exists
SUPERVISOR_CONF=/etc/supervisor/conf.d/supervisord.conf
if [ ! -f "$SUPERVISOR_CONF" ]; then
    sudo tee "$SUPERVISOR_CONF" > /dev/null <<EOF
# /etc/supervisor/conf.d/supervisord.conf
[program:casper-node-launcher]
user=jh
command=/usr/bin/casper-node-launcher
environment=CASPER_CONFIG_DIR="$NODE_ROOT/etc",CASPER_BIN_DIR="$NODE_ROOT/bin"
autostart=true
autorestart=true
startsecs=6
startretries=20
stdout_logfile=$NODE_ROOT/logs/casper-node.log
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stderr_logfile=$NODE_ROOT/logs/casper-node.err
stderr_logfile_maxbytes=20MB
stderr_logfile_backups=5
EOF
fi

sudo supervisorctl -c /etc/supervisor/supervisord.conf update
sudo supervisorctl -c /etc/supervisor/supervisord.conf start casper-node-launcher