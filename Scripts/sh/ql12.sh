#!/usr/bin/env bash

clear

echo -e "\e[36m
   ▄▄▄▄       ██                         ▄▄▄▄                                   
  ██▀▀██      ▀▀                         ▀▀██                                   
 ██    ██   ████     ██▄████▄   ▄███▄██    ██       ▄████▄   ██▄████▄   ▄███▄██ 
 ██    ██     ██     ██▀   ██  ██▀  ▀██    ██      ██▀  ▀██  ██▀   ██  ██▀  ▀██ 
 ██    ██     ██     ██    ██  ██    ██    ██      ██    ██  ██    ██  ██    ██ 
  ██▄▄██▀  ▄▄▄██▄▄▄  ██    ██  ▀██▄▄███    ██▄▄▄   ▀██▄▄██▀  ██    ██  ▀██▄▄███ 
   ▀▀▀██   ▀▀▀▀▀▀▀▀  ▀▀    ▀▀   ▄▀▀▀ ██     ▀▀▀▀     ▀▀▀▀    ▀▀    ▀▀   ▄▀▀▀ ██ 
       ▀                        ▀████▀▀                                 ▀████▀▀
\e[0m\n"

echo -------------------------------
echo "目前推荐版本 -  2.19.2 回车默认安装" 
echo "2.12.0   |   2.19.2"
echo -------------------------------
read -r -p "请输入要安装的青龙版本:" ql
if  [ ! -n "$ql" ] ;then
 ql="2.17.11"
 echo "您设置的当前版本${ql}"
else
  echo "您设置的当前版本${ql}"
fi 
echo -------------------------------
DOCKER_IMG_NAME="whyour/qinglong"
JD_PATH=""
SHELL_FOLDER=$(pwd)
CONTAINER_NAME=""
TAG="${ql}"
NETWORK="bridge"
JD_PORT=5700

HAS_IMAGE=false
PULL_IMAGE=true
HAS_CONTAINER=false
DEL_CONTAINER=true
INSTALL_WATCH=false
ENABLE_HANGUP=true
ENABLE_WEB_PANEL=true
OLD_IMAGE_ID=""
ENABLE_HANGUP_ENV="--env ENABLE_HANGUP=true"
ENABLE_WEB_PANEL_ENV="--env ENABLE_WEB_PANEL=true"


log() {
    echo -e "\e[32m\n$1 \e[0m\n"
}

inp() {
    echo -e "\e[33m\n$1 \e[0m\n"
}

opt() {
    echo -n -e "\e[36m输入您的选择->\e[0m"
}

warn() {
    echo -e "\e[31m$1 \e[0m\n"
}

cancelrun() {
    if [ $# -gt 0 ]; then
        echo -e "\e[31m $1 \e[0m"
    fi
    exit 1
}

docker_install() {
    echo "检测 Docker......"
    if [ -x "$(command -v docker)" ]; then
        echo "检测到 Docker 已安装!"
    else
        if [ -r /etc/os-release ]; then
            lsb_dist="$(. /etc/os-release && echo "$ID")"
        fi
        if [ $lsb_dist == "openwrt" ]; then
            echo "openwrt 环境请自行安装 docker"
            exit 1
        else
            echo "安装 docker 环境..."
            bash <(curl -sSL https://raw.githubusercontent.com/cydanyanpi/VIP/main/Scripts/sh/docker.sh)  --install-latested true --source https://mirrors.aliyun.com/docker-ce --source-registry https://registry.cn-hangzhou.aliyuncs.com --close-firewall 
            echo "安装 docker 环境...安装完成!"
            echo "添加Docker镜像加速器..."
           # 添加Docker镜像加速器设置
            rm -rf /etc/docker/daemon.json
            touch /etc/docker/daemon.json
            echo '{
                "registry-mirrors": [
                    "https://yanyu.icu",
                    "https://yanyuge.free.hr"
                ]
            }' | sudo tee /etc/docker/daemon.json
            echo "安装 docker 环境...安装完成!"
            systemctl enable docker
            systemctl start docker
            

        fi
    fi
}

docker_install
warn "Faker系列仓库一键安装配置，小白回车到底，一路默认选择"
# 配置文件保存目录
echo -n -e "\e[33m一、请输入配置文件保存的绝对路径（示例：/root)，回车默认为当前目录:\e[0m"
read jd_path
if [ -z "$jd_path" ]; then
    JD_PATH=$SHELL_FOLDER
elif [ -d "$jd_path" ]; then
    JD_PATH=$jd_path
else
    mkdir -p $jd_path
    JD_PATH=$jd_path
fi
DATA_PATH=$JD_PATH/ql


# 检测镜像是否存在
if [ ! -z "$(docker images -q $DOCKER_IMG_NAME:$TAG 2> /dev/null)" ]; then
    HAS_IMAGE=true
    OLD_IMAGE_ID=$(docker images -q --filter reference=$DOCKER_IMG_NAME:$TAG)
    inp "检测到先前已经存在的镜像，是否拉取最新的镜像：\n1) 拉取[默认]\n2) 不拉取"
    opt
    read update
    if [ "$update" = "2" ]; then
        PULL_IMAGE=false
    fi
fi

# 检测容器是否存在
check_container_name() {
    if [ ! -z "$(docker ps -a | grep $CONTAINER_NAME 2> /dev/null)" ]; then
        HAS_CONTAINER=true
        inp "检测到先前已经存在的容器，是否删除先前的容器：\n1) 删除[默认]\n2) 不删除"
        opt
        read update
        if [ "$update" = "2" ]; then
            PULL_IMAGE=false
            inp "您选择了不删除之前的容器，需要重新输入容器名称"
            input_container_name
        fi
    fi
}

# 容器名称
input_container_name() {
    echo -n -e "\e[33m\n二、请输入要创建的 Docker 容器名称[默认为：qinglong]->\e[0m"
    read container_name
    if [ -z "$container_name" ]; then
        CONTAINER_NAME="qinglong"
    else
        CONTAINER_NAME=$container_name
    fi
    check_container_name
}
input_container_name

# 是否安装 WatchTower
inp "是否安装 containrrr/watchtower 自动更新 Docker 容器：\n1) 安装\n2) 不安装[默认]"
opt
read watchtower
if [ "$watchtower" = "1" ]; then
    INSTALL_WATCH=true
fi

inp "请选择容器的网络类型：\n1) host\n2) bridge[默认]"
opt
read net
if [ "$net" = "1" ]; then
    NETWORK="host"
    MAPPING_JD_PORT=""
fi

inp "是否在启动容器时自动启动挂机程序：\n1) 开启[默认]\n2) 关闭"
opt
read hang_s
if [ "$hang_s" = "2" ]; then
    ENABLE_HANGUP_ENV=""
fi

inp "是否启用青龙面板：\n1) 启用[默认]\n2) 不启用"
opt
read pannel
if [ "$pannel" = "2" ]; then
    ENABLE_WEB_PANNEL_ENV=""
fi


# 端口问题
modify_ql_port() {
    inp "是否修改青龙端口[默认 5700]：\n1) 推荐！避免CK被偷请修改\n2) 不修改[不建议，强烈建议修改！]"
    opt
    read change_ql_port
    if [ "$change_ql_port" = "1" ]; then
        echo -n -e "\e[36m输入您想修改的端口->\e[0m"
        read JD_PORT
    fi
}
if [ "$NETWORK" = "bridge" ]; then
    inp "是否映射端口：\n1) 映射[默认]\n2) 不映射"
    opt
    read port
    if [ "$port" = "2" ]; then
        MAPPING_JD_PORT=""
    else
        modify_ql_port
    fi
fi


# 配置已经创建完成，开始执行
log "1.开始创建配置文件目录"
PATH_LIST=($DATA_PATH  )
for i in ${PATH_LIST[@]}; do
    mkdir -p $i
done
 
if [ $HAS_CONTAINER = true ] && [ $DEL_CONTAINER = true ]; then
    log "2.1.删除先前的容器"
    docker stop $CONTAINER_NAME >/dev/null
    docker rm $CONTAINER_NAME >/dev/null
fi

if [ $HAS_IMAGE = true ] && [ $PULL_IMAGE = true ]; then
    if [ ! -z "$OLD_IMAGE_ID" ] && [ $HAS_CONTAINER = true ] && [ $DEL_CONTAINER = true ]; then
        log "2.2.删除旧的镜像"
        docker image rm $OLD_IMAGE_ID 
    fi
    log "2.3.开始拉取最新的镜像"
    docker pull $DOCKER_IMG_NAME:$TAG
    if [ $? -ne 0 ] ; then
        cancelrun "** 错误：拉取不到镜像！"
    fi
fi

# 端口存在检测
check_port() {
    echo "正在检测端口:$1"
    netstat -tlpn | grep "\b$1\b"
}
if [ "$port" != "2" ]; then
    while check_port $JD_PORT; do    
        echo -n -e "\e[31m端口:$JD_PORT 被占用，请重新输入青龙面板端口：\e[0m"
        read JD_PORT
    done
    echo -e "\e[34m恭喜，端口:$JD_PORT 可用\e[0m"
    MAPPING_JD_PORT="-p $JD_PORT:5700"
fi


log "3.开始创建容器并执行"
docker run -dit \
    -t \
    -v $DATA_PATH:/ql/data \
    $MAPPING_JD_PORT \
    --name $CONTAINER_NAME \
    --hostname qinglong \
    --restart always \
    --network $NETWORK \
    $ENABLE_HANGUP_ENV \
    $ENABLE_WEB_PANEL_ENV \
    $DOCKER_IMG_NAME:$TAG

if [ $? -ne 0 ] ; then
    cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
fi

if [ $INSTALL_WATCH = true ]; then
    log "3.1.开始创建容器并执行"
    docker run -d \
    --name watchtower \
    --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower -c\
    --schedule "13,14,15 3 * * * *" \
    $CONTAINER_NAME
fi

# 检查 config 文件是否存在
# 检查是否为 2.17.11 版本，如果不是，则执行配置文件复制操作
if [ "$ql" != "2.17.11" ]; then
    if [ ! -f "$DATA_PATH/config.sh" ]; then
        docker cp $CONTAINER_NAME:/ql/sample/config.sample.sh $DATA_PATH/config/config.sh
        if [ $? -ne 0 ] ; then
            cancelrun "** 错误：找不到配置文件！"
        fi
    fi
else
    echo "当前版本为 2.17.11，不需要复制配置文件"
fi

log "4.下面列出所有容器"
docker ps

# Nginx 静态解析检测
log "5.开始检测 Nginx 静态解析"
echo "开始扫描静态解析是否在线！"
ps -fe|grep nginx|grep -v grep
if [ $? -ne 0 ]; then
    echo "$(date +%Y-%m-%d" "%H:%M:%S) 扫描结束！Nginx 静态解析停止！准备重启！"
    docker exec -it $CONTAINER_NAME nginx -c /etc/nginx/nginx.conf
    echo "$(date +%Y-%m-%d" "%H:%M:%S) Nginx 静态解析重启完成！"
else
    echo "$(date +%Y-%m-%d" "%H:%M:%S) 扫描结束！Nginx 静态解析正常！"
fi

if [ "$port" = "2" ]; then
    log "6.安装已完成，请自行调整端口映射并进入面板一次以便进行内部配置"
else
    log "6.安装已完成，请进入面板一次以便进行内部配置"
    log "6.1.用户名和密码已显示，请登录 ip:$JD_PORT"
   # cat $DATA_PATH/config/auth.json
    echo -e "\n"
fi

# 防止 CPU 占用过高导致死机
echo -e "-------- 机器累了，休息 20s，趁机去操作一下吧 --------"
sleep 20

# 显示 auth.json
inp "是否显示被修改的密码：\n1) 显示[默认]\n2) 不显示"
opt
read display
if [ "$display" != "2" ]; then
    echo -e "\n"
    cat $DATA_PATH/config/auth.json
    echo -e "\n"
    log "6.2.用被修改的密码登录面板并进入"
fi  

# token 检测
inp "是否已进入面板：\n1) 进入[默认]\n2) 未进入"
opt
read access
log "6.3.观察 token 是否成功生成"
cat $DATA_PATH/config/auth.json
echo -e "\n"
if [ "$access" != "2" ]; then
    if [ "$(grep -c "token" $DATA_PATH/config/auth.json)" != 0 ]; then
        log "8.开始青龙内部配置"
        docker exec -it $CONTAINER_NAME bash -c "$(curl -fsSL https://raw.githubusercontent.com/yanyuwangluo/VIP/main/Scripts/sh/1customCDNN.sh)"
    else
        warn "8.未检测到 token，取消内部配置，后续配置去教程看即可"
    fi
else
    exit 0
fi

log "/n部署完成了，另外Faker教程内有一键安装依赖脚本，请继续安装使用"
