# 搭建一套三站点的vpn网络，使得站点内机器可以互相通信

## 机器分配与网络规划（约定）

总共分配三台主机，分别位于三个子网中，运行openvpn进程，按照ip地址从小到大命名为vpn1、vpn2、vpn3。

| 实例名称 |      所在网段       |     IP地址     |   角色   |
|:----:|:---------------:|:------------:|:------:|
| vpn1 | 192.168.10.0/24 | 192.168.10.4 | 1-2客户端 |
| vpn2 | 192.168.20.0/24 | 192.168.20.4 | 1-2客户端 |
| vpn3 | 192.168.30.0/24 | 192.168.30.4 | 1-2客户端 |

在三台主机中间，两两组合成一对，搭建openvpn点对点链路。在每一组中，ip地址小的作为客户端，大的作为服务器，特殊在于vpn3和vpn1链路中，vpn3作为客户端，vpn1作为服务器。

再做一个约定，在使用共享密钥时（--secret），明确指定direction属性，其中客户端使用1，服务器使用0。

|    vpn链路    | 客户端主机 | 服务器主机 |          服务器地址           |     vpn网段     |   客户端侧地址   |   服务器侧地址    |           使用的静态共享密钥           |
|:-----------:|:-----:|:-----:|:------------------------:|:-------------:|:----------:|:-----------:|:-----------------------------:|
| vpn1-vpn2链路 | vpn1  | vpn2  | openvpn2.lgypro.com:1194 | 10.200.0.0/30 | 10.200.0.1 | 10.200.0.2  | secret12.key，在vpn2生成，复制到vpn1上 |
| vpn2-vpn3链路 | vpn2  | vpn3  | openvpn3.lgypro.com:1194 | 10.200.0.4/30 | 10.200.0.5 | 10.200.0.6  |
| vpn3-vpn1链路 | vpn3  | vpn1  | openvpn1.lgypro.com:1194 | 10.200.0.8/30 | 10.200.0.9 | 10.200.0.10 |

## 配置过程

```bash
apt update
apt -y install easy-rsa openvpn
```

### vpn1-vpn2链路的配置

vpn1作为客户端，vpn2作为服务器

在vpn2上执行

```bash
openvpn --genkey secret secret12.key
```

把共享密钥文件拷贝到/etc/openvpn/server/secret12.key和vpn1上的/etc/openvpn/client/secret12.key

```bash
cat > /etc/openvpn/server/server.conf << 'EOF'
dev tun
proto udp
local 192.168.20.4
port 1194
secret secret12.key 0
ifconfig 10.200.0.2 10.200.0.1
# 到对端网络
route 192.168.10.0 255.255.255.0 vpn_gateway 100
# 经该vpn链路中转，到第三个网络
route 192.168.30.0 255.255.255.0 vpn_gateway 200
user nobody
group nogroup
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 7
EOF
systemctl start openvpn-server@server
systemctl status openvpn-server@server.service
journalctl -u openvpn-server@server.service
# workaround，向其余两个网段发送数据包的时候，通过POSTROUTING修改源地址，暂时还没想到其他好方案
iptables -t nat -A POSTROUTING -d 192.168.10.0/24 -s 10.200.0.0/30 -j SNAT --to-source 192.168.20.4
iptables -t nat -A POSTROUTING -d 192.168.30.0/24 -s 10.200.0.0/30 -j SNAT --to-source 192.168.20.4
```

在vpn1上执行

```bash
cat > /etc/openvpn/client/client.conf << 'EOF'
dev tun
proto udp
remote openvpn2.lgypro.com 1194
secret secret12.key 1
ifconfig 10.200.0.1 10.200.0.2
# 到对端网络
route 192.168.20.0 255.255.255.0 vpn_gateway 100
# 经该vpn链路中转，到第三个网络
route 192.168.30.0 255.255.255.0 vpn_gateway 200
user nobody
group nogroup
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 7
EOF
systemctl start openvpn-client@client
systemctl status openvpn-client@client
journalctl -u openvpn-client@client
# workaround，向其余两个网段发送数据包的时候，通过POSTROUTING修改源地址，暂时还没想到其他好方案
iptables -t nat -A POSTROUTING -d 192.168.20.0/24 -s 10.200.0.0/30 -j SNAT --to-source 192.168.10.4
iptables -t nat -A POSTROUTING -d 192.168.30.0/24 -s 10.200.0.0/30 -j SNAT --to-source 192.168.10.4
```

### vpn2-vpn3链路的配置

vpn2作为客户端，vpn3作为服务器

在vpn3上执行

```bash
openvpn --genkey secret secret23.key
```

把共享密钥文件拷贝到/etc/openvpn/server/secret23.key和vpn2上的/etc/openvpn/client/secret23.key

```bash
cat > /etc/openvpn/server/server.conf << 'EOF'
dev tun
proto udp
local 192.168.30.4
port 1194
secret secret23.key 0
ifconfig 10.200.0.6 10.200.0.5
# 到对端网络
route 192.168.20.0 255.255.255.0 vpn_gateway 100
# 经该vpn链路中转，到第三个网络
route 192.168.10.0 255.255.255.0 vpn_gateway 200
user nobody
group nogroup
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 7
EOF
systemctl start openvpn-server@server
systemctl status openvpn-server@server.service
journalctl -u openvpn-server@server.service
# workaround，向其余两个网段发送数据包的时候，通过POSTROUTING修改源地址，暂时还没想到其他好方案
iptables -t nat -A POSTROUTING -d 192.168.20.0/24 -s 10.200.0.4/30 -j SNAT --to-source 192.168.30.4
iptables -t nat -A POSTROUTING -d 192.168.10.0/24 -s 10.200.0.4/30 -j SNAT --to-source 192.168.30.4
```

在vpn2上执行

```bash
cat > /etc/openvpn/client/client.conf << 'EOF'
dev tun
proto udp
remote openvpn3.lgypro.com 1194
secret secret23.key 1
ifconfig 10.200.0.5 10.200.0.6
# 到对端网络
route 192.168.30.0 255.255.255.0 vpn_gateway 100
# 经该vpn链路中转，到第三个网络
route 192.168.10.0 255.255.255.0 vpn_gateway 200
user nobody
group nogroup
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 7
EOF
systemctl start openvpn-client@client
systemctl status openvpn-client@client
journalctl -u openvpn-client@client
# workaround，向其余两个网段发送数据包的时候，通过POSTROUTING修改源地址，暂时还没想到其他好方案
iptables -t nat -A POSTROUTING -d 192.168.30.0/24 -s 10.200.0.4/30 -j SNAT --to-source 192.168.20.4
iptables -t nat -A POSTROUTING -d 192.168.10.0/24 -s 10.200.0.4/30 -j SNAT --to-source 192.168.20.4
```

# vpn3-vpn1链路的配置

vpn3作为客户端，vpn1作为服务器

在vpn1上执行

```bash
openvpn --genkey secret secret31.key
```

把共享密钥文件拷贝到/etc/openvpn/server/secret31.key和vpn3上的/etc/openvpn/client/secret31.key

```bash
cat > /etc/openvpn/server/server.conf << 'EOF'
dev tun
proto udp
local 192.168.10.4
port 1194
secret secret31.key 0
ifconfig 10.200.0.10 10.200.0.9
# 到对端网络
route 192.168.30.0 255.255.255.0 vpn_gateway 100
# 经该vpn链路中转，到第三个网络
route 192.168.20.0 255.255.255.0 vpn_gateway 200
user nobody
group nogroup
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 7
EOF
systemctl start openvpn-server@server
systemctl status openvpn-server@server.service
journalctl -u openvpn-server@server.service
# workaround，向其余两个网段发送数据包的时候，通过POSTROUTING修改源地址，暂时还没想到其他好方案
iptables -t nat -A POSTROUTING -d 192.168.30.0/24 -s 10.200.8.0/30 -j SNAT --to-source 192.168.10.4
iptables -t nat -A POSTROUTING -d 192.168.20.0/24 -s 10.200.8.0/30 -j SNAT --to-source 192.168.10.4
```

在vpn3上执行

```bash
cat > /etc/openvpn/client/client.conf << 'EOF'
dev tun
proto udp
remote openvpn1.lgypro.com 1194
secret secret31.key 1
ifconfig 10.200.0.9 10.200.0.10
# 到对端网络
route 192.168.10.0 255.255.255.0 vpn_gateway 100
# 经该vpn链路中转，到第三个网络
route 192.168.20.0 255.255.255.0 vpn_gateway 200
user nobody
group nogroup
persist-tun
persist-key
keepalive 10 60
ping-timer-rem
verb 7
EOF
systemctl start openvpn-client@client
systemctl status openvpn-client@client
journalctl -u openvpn-client@client
# workaround，向其余两个网段发送数据包的时候，通过POSTROUTING修改源地址，暂时还没想到其他好方案
iptables -t nat -A POSTROUTING -d 192.168.10.0/24 -s 10.200.0.8/30 -j SNAT --to-source 192.168.30.4
iptables -t nat -A POSTROUTING -d 192.168.20.0/24 -s 10.200.0.8/30 -j SNAT --to-source 192.168.30.4
```
