# 自建 Docker 镜像加速&缓存服务

> 利用 Registry 的 [镜像代理与缓存](https://docs.docker.com/registry/recipes/mirror/) 功能加速&缓存镜像，同时支持 dockerhub、gcr.io、quay.io、nvcr.io、registry.k8s.io 等多个仓库，保持原有仓库的镜像tag不变，且一次拉取之后打包整个仓库目录可离线使用，

## 1. 安装docker

```sh
git clone https://github.com/brighill/registry-mirror.git
cd registry-mirror
./get-docker.sh --mirror Aliyun
```

## 2. 生成证书

```sh
./gencert.sh
```

## 3. 启动服务端
设置代理（可选）
```sh
# 例1: socks5 代理 ip 192.168.1.1  端口 1080
export PROXY=socks5://192.168.1.1:1080

# 例2: http 代理ip 192.168.1.1 端口 1080
export PROXY=http://192.168.1.1:1080
```

*启动服务*

```sh
docker compose up -d
```

## 4. 配置客户端
### 劫持域名解析

*以自建仓库ip为192.168.1.1为例，修改/etc/hosts 添加以下内容*  

```sh
192.168.1.1 gcr.io quay.io docker.io registry-1.docker.io nvcr.io registry.k8s.io custom.local
```

### 信任证书

需要把生成的 **cert/ca.crt** 拷贝到客户端 

```sh
# macOS
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain cert/ca.crt
```

```sh
# Debian/Ubuntu
sudo apt install ca-certificates
sudo cp cert/ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates
```

```sh
# CentOS/Fedora/RHEL
sudo yum install ca-certificates
sudo update-ca-trust force-enable
sudo cp cert/ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

### 重启docker

```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 测试

```sh
# Docker Hub
docker pull alpine
# registry.k8s.io
docker pull registry.k8s.io/pause:3.9
# quay.io
docker pull quay.io/coreos/etcd:v3.4.33
# gcr.io
docker pull gcr.io/google-containers/pause:3.2
# ghcr.io
docker pull ghcr.io/coder/coder:v2.13.0
# nvcr.io
docker pull nvcr.io/nvidia/k8s/cuda-sample:devicequery
```
