#!/usr/bin/env bash
#github拉库修复 运行一次就好
#

# 设置 http.postBuffer
echo "设置 github缓存配置....."
git config --global http.postBuffer 524288000

# 查看 http.postBuffer 配置
POST_BUFFER_VALUE=$(git config --global http.postBuffer)
echo "http.postBuffer 的值是: $POST_BUFFER_VALUE"
if [ "$POST_BUFFER_VALUE" != "524288000" ]; then
    echo "http.postBuffer 设置失败"
    exit 1
fi

# 设置 http.sslVerify
echo "设置 github拉库SSL检验配置...."
git config --global http.sslVerify "false"

# 查看 http.sslVerify 配置
SSL_VERIFY_VALUE=$(git config --global http.sslVerify)
echo "http.sslVerify 的值是: $SSL_VERIFY_VALUE"
if [ "$SSL_VERIFY_VALUE" != "false" ]; then
    echo "http.sslVerify 设置失败"
    exit 1
fi

echo "github拉库修复完成"
exit 0
