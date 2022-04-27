#!/bin/bash

for idx in `seq 6000 6005`; do
  mkdir -p ./$idx/conf
  file=./$idx/conf/redis.conf
  touch $file

  # 重写该文件
  echo "" > $file

  echo "port $idx" >> $file
  echo "bind 0.0.0.0" >> $file
  echo "" >> $file
  echo "# cluster configs" >> $file
  echo "cluster-enabled yes" >> $file
  echo "protected-mode no" >> $file
  echo "cluster-config-file nodes.conf" >> $file
  echo "cluster-node-timeout 5000" >> $file
  echo "masterauth admin" >> $file
  echo "requirepass admin" >> $file
  echo "" >> $file
  echo "# 对外ip" >> $file
  echo "cluster-announce-ip 192.168.22.10" >> $file
  echo "cluster-announce-port $idx" >> $file
  echo "cluster-announce-bus-port 1$idx" >> $file
  echo "appendonly yes" >> $file

done
