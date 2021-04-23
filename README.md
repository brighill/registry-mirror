# 自建Docker镜像加速&缓存服务

> 利用Docker镜像仓库的[镜像代理与缓存](https://docs.docker.com/registry/recipes/mirror/) 功能加速镜像下载，并使用nginx根据域名进行分流，客户端通过自建仓库拉取镜像并缓存在服务端，加快镜像拉取速度。

## 1.启动服务端
```sh
git clone https://github.com/brighill/registry-mirror.git
cd registry-mirror
# 如果在无法访问gcr.io的机器上启动服务则需要增加代理
# export PROXY=ip:port
docker-compose up -d
```

## 2.修改客户端DNS记录
将需要加速的域名解析为服务端的IP(如果有内网DNS服务则在DNS服务端修改)
```sh
#/etc/hosts 
192.168.1.1 gcr.io k8s.gcr.io quay.io docker.io registry-1.docker.io nvcr.io custom.local
```

## 3.配置客户端docker
```sh
### 方法1: 修改/etc/systemd/system/docker.service.d/docker-options.conf
[Service]
Environment="DOCKER_OPTS=--insecure-registry=gcr.io --insecure-registry=k8s.gcr.io --insecure-registry=quay.io --insecure-registry=docker.io --insecure-registry=registry-1.docker.io --insecure-registry=nvcr.io --insecure-registry=custom.local --registry-mirror=http://registry-1.docker.io"

### 方法2: /etc/docker/daemon.json 
"insecure-registries" : ["gcr.io", "k8s.gcr.io", "quay.io", "docker.io", "registry-1.docker.io", "nvic.io", "custom.local"]
```

## 4.重启客户端docker服务
```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 5.测试
```sh
docker pull gcr.io/google_containers/pause-amd64:3.2
```
