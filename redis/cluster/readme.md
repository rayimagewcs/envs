
# 1. run generateConf.sh to generate redis configs

```sh
bash generateConf.sh
```

# 2. run up redis containers

```
docker-compose up -d
```

# 3. entry docker redis0 container

```
docker exec -it redis0 bash
```

# 4. create redis cluster

```sh
redis-cli --cluster create --cluster-replicas 1 192.168.22.10:6000 192.168.22.10:6001 \
  192.168.22.10:6002 192.168.22.10:6003 192.168.22.10:6004 192.168.22.10:6005 -a admin
```

# 5. connect to redis cluster

using `-c` option to connect to cluster

```
redis-cli -c -a admin -p 6000
auth admin
cluster info
cluster nodes
```
