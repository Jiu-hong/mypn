when upgrade from 1.0.0 to 2.0.0, create this file before upgrade hits
sudo -u casper touch /var/lib/casper/casper-node/sse_index

## STEP1

start server where casper-node software is hosted:

```bash
npm run start
```

test

```bash
curl mynetwork.local:5000/mynetwork/protocol_versions
```

## STEP2

### create config.tar.gz

### STEP2.1

```bash
rm public/mynetwork/1_0_0/config.tar.gz
tar -czvf public/mynetwork/1_0_0/config.tar.gz -C example/1_0_0 .

rm public/mynetwork/1_2_0/config.tar.gz
tar -czvf public/mynetwork/1_2_0/config.tar.gz -C example/1_2_0 .

rm public/mynetwork/1_3_2/config.tar.gz
tar -czvf public/mynetwork/1_3_2/config.tar.gz -C example/1_3_2 .

rm public/mynetwork/1_3_4/config.tar.gz
tar -czvf public/mynetwork/1_3_4/config.tar.gz -C example/1_3_4 .

rm public/mynetwork/1_4_1/config.tar.gz
tar -czvf public/mynetwork/1_4_1/config.tar.gz -C example/1_4_1 .

rm public/mynetwork/1_4_3/config.tar.gz
tar -czvf public/mynetwork/1_4_3/config.tar.gz -C example/1_4_3 .

rm public/mynetwork/1_4_4/config.tar.gz
tar -czvf public/mynetwork/1_4_4/config.tar.gz -C example/1_4_4 .

rm public/mynetwork/1_4_5/config.tar.gz
tar -czvf public/mynetwork/1_4_5/config.tar.gz -C example/1_4_5 .

rm public/mynetwork/1_4_6/config.tar.gz
tar -czvf public/mynetwork/1_4_6/config.tar.gz -C example/1_4_6 .

rm public/mynetwork/1_5_1/config.tar.gz
tar -czvf public/mynetwork/1_5_1/config.tar.gz -C example/1_5_1 .

rm public/mynetwork/1_5_8/config.tar.gz
tar -czvf public/mynetwork/1_5_8/config.tar.gz -C example/1_5_8 .


rm public/mynetwork/2_0_0/config.tar.gz
tar -czvf public/mynetwork/2_0_0/config.tar.gz -C example/2_0_0 .

rm public/mynetwork/2_0_4/config.tar.gz
tar -czvf public/mynetwork/2_0_4/config.tar.gz -C example/2_0_4 .

rm public/mynetwork/2_1_1/config.tar.gz
tar -czvf public/mynetwork/2_1_1/config.tar.gz -C example/2_1_1 .

rm public/mynetwork/2_1_2/config.tar.gz
tar -czvf public/mynetwork/2_1_2/config.tar.gz -C example/2_1_2 .

rm public/mynetwork/2_2_0/config.tar.gz
tar -czvf public/mynetwork/2_2_0/config.tar.gz -C example/2_2_0 .

rm public/mynetwork/2_2_1/config.tar.gz
tar -czvf public/mynetwork/2_2_1/config.tar.gz -C example/2_2_1 .

rm public/mynetwork/2_2_2/config.tar.gz
tar -czvf public/mynetwork/2_2_2/config.tar.gz -C example/2_2_2 .
```

### STEP2.2

### build casper-node binary:

```bash
docker build --no-cache -f casper-node.Dockerfile --output . -t casper-node .
```

### STEP2.3

### create bin.tar.gz

```bash
# cp docker-compile/tmp/casper-node/bin.tar.gz binary/1.0.0
cp binary/1.0.0/bin.tar.gz public/mynetwork/1_0_0/bin.tar.gz
cp binary/1.2.0/bin.tar.gz public/mynetwork/1_2_0/bin.tar.gz
cp binary/1.3.2/bin.tar.gz public/mynetwork/1_3_2/bin.tar.gz
cp binary/1.3.4/bin.tar.gz public/mynetwork/1_3_4/bin.tar.gz
cp binary/1.4.1/bin.tar.gz public/mynetwork/1_4_1/bin.tar.gz
cp binary/1.4.3/bin.tar.gz public/mynetwork/1_4_3/bin.tar.gz
cp binary/1.4.4/bin.tar.gz public/mynetwork/1_4_4/bin.tar.gz
cp binary/1.4.5/bin.tar.gz public/mynetwork/1_4_5/bin.tar.gz
cp binary/1.4.6/bin.tar.gz public/mynetwork/1_4_6/bin.tar.gz

cp binary/1.5.1/bin.tar.gz public/mynetwork/1_5_1/bin.tar.gz
cp binary/1.5.8/bin.tar.gz public/mynetwork/1_5_8/bin.tar.gz

cp binary/2.0.0/bin.tar.gz public/mynetwork/2_0_0/bin.tar.gz
cp binary/2.0.4/bin.tar.gz public/mynetwork/2_0_4/bin.tar.gz
cp binary/2.1.1/bin.tar.gz public/mynetwork/2_1_1/bin.tar.gz

# cp docker-compile/tmp/casper-node/bin.tar.gz binary/2.1.3
cp binary/2.2.0/bin.tar.gz public/mynetwork/2_2_0/bin.tar.gz

cp public/mynetwork/2_2_0/bin.tar.gz public/mynetwork/2_2_1/bin.tar.gz
```
