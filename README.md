# 自建Docker镜像加速&缓存服务

> 利用Docker镜像仓库的[镜像代理与缓存](https://docs.docker.com/registry/recipes/mirror/) 功能加速镜像下载，并使用 nginx 根据域名进行分流，客户端通过自建仓库拉取镜像并缓存在服务端，加快镜像拉取速度。

## 启动服务端
```sh
git clone https://github.com/brighill/registry-mirror.git
cd registry-mirror
#生成证书
./gencert.sh
# 如果在无法访问gcr.io的机器上启动服务则需要增加代理
# export PROXY=ip:port
docker-compose up -d
```

## 配置客户端
修改/etc/hosts将域名解析劫持到自己的IP(如果有自建DNS服务也可以改DNS配置)
```sh
#vim /etc/hosts 
192.168.1.1 gcr.io k8s.gcr.io quay.io docker.io registry-1.docker.io nvcr.io registry.k8s.io custom.local
```

信任证书（不同操作系统步骤可能不一样）
```sh
# Gentoo
sudo emerge app-misc/ca-certificates
sudo mkdir -p  /usr/local/share/ca-certificates/
sudo cp cert/ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates
```

```sh
# Debian/Ubuntu
sudo apt install ca-certificates
sudo cp cert/ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates
```

```sh
#CentOS/Fedora/RHEL
sudo yum install ca-certificates
sudo update-ca-trust force-enable
sudo cp cert/ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

重启docker
```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
```

测试

```sh
docker pull registry.k8s.io/pause:3.9
```
