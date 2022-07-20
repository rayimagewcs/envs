
# Nodejs基于HTTP2.0 Server

参考`nodejs`官网说明`Since there are no browsers known that support unencrypted HTTP/2, the use of 
http2.createSecureServer() is necessary when communicating with browser clients.`

因此要使用`HTTP2.0`则必须使用`https`，因此接下来基于`https`创建一个服务端，并通过浏览器和代码分别演示客户端发起请求并有服务端正确处理请求及响应。

## 1、生产秘钥和证书

```shell
# 1、生成私钥，同时由des3算法加密，如果不想使用密码，可以使用
# openssl genrsa -out privkey.pem 2048
$ openssl genrsa -des3 -out privkey.pem 2048

# 2、基于私钥生成证书，有两种方式可以获取证书
# 方式一：先生成一个证书请求（cert.csr文件），获取证书请求后，拿着这个文件去数字证书颁发机构（即CA）申请一个数字证书。CA会给你一个新的文件cacert.pem即数字证书
$ openssl req -new -key privkey.pem -out cert.csr

# 方式二：自己测试用，则只需要本地生成一个即可
$ openssl req -new -x509 -key privkey.pem -out cacert.pem -days 1095
```
