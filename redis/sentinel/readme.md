# `redis sentinel`集群搭建

搭建好redis集群后，处于对高可用需求，可以通过sentinel机制对redis集群进行监控，当集群中有master节点挂掉后，哨兵可以发现并通过选举机制产生新的master节点

## 1、`docker pull bitnami/redis-sentinel`

```
docker pull bitnami/redis-sentinel
```

## 2、新建 `docker-compose.yml`

## 3、启动

```
docker-compose up --scale redis-sentinel=3 -d
```

## 4、验证`sentinel`是否生效

```
d1a57308fc5e547315b4082f5d25b36575df16a7 192.168.22.10:6005@16005 slave,fail 8799a9bb22e079fbdd1f5e5ee5ac9f2827382f50 1651116117188 1651116116886 8 disconnected
37ed40d95812fa02e329d94f07bdb8fad8608bf6 192.168.22.10:6004@16004 master - 0 1651731324000 9 connected 0-5460
d2bae0c8f83a9de61eeb90319d92693e522cd10a 192.168.22.10:6003@16003 slave f9fbea087503bb9bc5c34e56d9ad7a5c8c0e19e0 0 1651731325872 3 connected
f9fbea087503bb9bc5c34e56d9ad7a5c8c0e19e0 192.168.22.10:6002@16002 master - 0 1651731324864 3 connected 10923-16383
8799a9bb22e079fbdd1f5e5ee5ac9f2827382f50 192.168.22.10:6001@16001 myself,master - 0 1651731325000 8 connected 5461-10922
1e0093e462d4f1dd729b25cc329a4c3e392a6c93 192.168.22.10:6000@16000 slave 37ed40d95812fa02e329d94f07bdb8fad8608bf6 0 1651731325369 9 connected
```

可以看出当前节点主从关系：

```
master      slave
6001        6005
6002        6003
6004        6000
```

关闭 6004 master 节点后，sentinel 输出如下日志：

```
1:X 05 May 2022 06:16:49.299 # +sdown master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:49.352 # +odown master mymaster 172.38.0.1 6004 #quorum 4/2
1:X 05 May 2022 06:16:49.352 # +new-epoch 3289
1:X 05 May 2022 06:16:49.352 # +try-failover master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:49.374 # +vote-for-leader e8425db4a8890679bed41dfafb3f7818405d52b1 3289
1:X 05 May 2022 06:16:49.375 # f95ff1359adf2d69f3de9c113cc111a4ee84e288 voted for e8425db4a8890679bed41dfafb3f7818405d52b1 3289
1:X 05 May 2022 06:16:49.375 # 17789a8ef2c388315900f51c64d9ea471f5f35ef voted for e8425db4a8890679bed41dfafb3f7818405d52b1 3289
1:X 05 May 2022 06:16:49.375 # e8425db4a8890679bed41dfafb3f7818405d52b1 voted for e8425db4a8890679bed41dfafb3f7818405d52b1 3289
1:X 05 May 2022 06:16:49.441 # +elected-leader master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:49.441 # +failover-state-select-slave master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:49.518 # +selected-slave slave 172.38.0.1:6000 172.38.0.1 6000 @ mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:49.518 * +failover-state-send-slaveof-noone slave 172.38.0.1:6000 172.38.0.1 6000 @ mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:49.573 * +failover-state-wait-promotion slave 172.38.0.1:6000 172.38.0.1 6000 @ mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:50.418 # +promoted-slave slave 172.38.0.1:6000 172.38.0.1 6000 @ mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:50.418 # +failover-state-reconf-slaves master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:16:50.467 * +slave-reconf-sent slave 192.168.22.10:6000 192.168.22.10 6000 @ mymaster 172.38.0.1 6004
1:X 05 May 2022 06:19:50.476 # +failover-end-for-timeout master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:19:50.476 # +failover-end master mymaster 172.38.0.1 6004
1:X 05 May 2022 06:19:50.476 # +switch-master mymaster 172.38.0.1 6004 172.38.0.1 6000
```

可以看出sentinel检测到了 6004 master down，并选举出 6000 作为新的 master 节点，即表明sentinel已经生效。

```
127.0.0.1:6001> cluster nodes
d1a57308fc5e547315b4082f5d25b36575df16a7 192.168.22.10:6005@16005 slave,fail 8799a9bb22e079fbdd1f5e5ee5ac9f2827382f50 1651116117188 1651116116886 8 disconnected
37ed40d95812fa02e329d94f07bdb8fad8608bf6 192.168.22.10:6004@16004 master,fail - 1651731349248 1651731347032 9 disconnected
d2bae0c8f83a9de61eeb90319d92693e522cd10a 192.168.22.10:6003@16003 slave f9fbea087503bb9bc5c34e56d9ad7a5c8c0e19e0 0 1651731962845 3 connected
f9fbea087503bb9bc5c34e56d9ad7a5c8c0e19e0 192.168.22.10:6002@16002 master - 0 1651731961837 3 connected 10923-16383
8799a9bb22e079fbdd1f5e5ee5ac9f2827382f50 192.168.22.10:6001@16001 myself,master - 0 1651731962000 8 connected 5461-10922
1e0093e462d4f1dd729b25cc329a4c3e392a6c93 192.168.22.10:6000@16000 master - 0 1651731961535 10 connected 0-5460
```
