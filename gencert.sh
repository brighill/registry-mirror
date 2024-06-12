#!/bin/bash

# 检查 OpenSSL 命令是否存在
if ! command -v openssl &>/dev/null; then
    echo "错误：未安装 OpenSSL 或未将其添加到 PATH 中。"
    exit 1
fi

read -s -p "设置 CA 密码：" password
echo ""

# 创建 cert 目录
cert_dir="cert"
mkdir -p $cert_dir

# 证书的基本信息
days=3650
country="CN"
state="Shanghai"
locality="Shanghai"
organization="registry"
organizational_unit="registry"
common_name="registry.com"
alt_names="DNS:gcr.io,DNS:ghcr.io,DNS:*.k8s.io,DNS:*.docker.io,DNS:quay.io,DNS:nvcr.io,DNS:custom.local"

# 生成自签名的 CA 私钥和证书
generate_ca() {
    echo "正在生成自签名的 CA 私钥和证书..."
    openssl genrsa -des3 -out $cert_dir/ca.key -passout pass:"$password" 4096
    openssl req -x509 -new -key $cert_dir/ca.key -out $cert_dir/ca.crt -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizational_unit/CN=$common_name" -days $days -passin pass:"$password"
}

# 生成服务器证书签署请求（CSR）和私钥
generate_server_csr() {
    echo "正在生成服务器证书签署请求（CSR）和私钥..."
    openssl req -new -keyout $cert_dir/server.key -out $cert_dir/server.csr -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizational_unit/CN=$common_name" -nodes
}

# 使用 CA 对 CSR 进行签名，生成服务器证书
sign_server_certificate() {
    echo "正在使用 CA 对 CSR 进行签名，生成服务器证书..."
    openssl x509 -req -in $cert_dir/server.csr -CA $cert_dir/ca.crt -CAkey $cert_dir/ca.key -CAcreateserial -out $cert_dir/server.crt -days $days -extfile <(echo "subjectAltName=$alt_names") -passin pass:"$password"
}

# 执行证书生成流程
main() {
    generate_ca
    generate_server_csr
    sign_server_certificate
}

main

