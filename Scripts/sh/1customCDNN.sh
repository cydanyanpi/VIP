#!/usr/bin/env bash

## 本脚本搬运并模仿 liuqitoday
dir_config=/ql/data/config
dir_script=/ql/data/scripts
dir_repo=/ql/data/repo
dir_deps=/ql/data/deps
config_shell_path=$dir_config/config.sh
extra_shell_path=$dir_config/extra.sh
code_shell_path=$dir_config/code.sh
task_before_shell_path=$dir_config/task_before.sh
# 定义 gitfix.sh 路径
git_shell_path=$dir_config/gitfix.sh
sendNotify_js_path=$dir_config/sendNotify.js
sendNotify_deps_path=$dir_deps/sendNotify.js
sendNotify_scripts_path=$dir_script/sendNotify.js



# 控制是否执行变量
read -p "是否执行全部操作，输入 1 即可执行全部，输入 0 则跳出，回车默认和其他可进行选择性操作，建议初次配置输入 1：" all
if [ "${all}" = 1 ]; then
    echo "将执行全部操作"
elif [ "${all}" = 0 ]; then
    exit 0
else
    read -p "config.sh 操作（替换或下载选项为 y，不替换为 n，回车为替换）请输入：" Rconfig
    Rconfig=${Rconfig:-'y'}
    read -p "extra.sh 操作（替换或下载选项为 a，修改设置区设置为 b，添加到定时任务为 c，立即执行一次为 d，全部不执行为 n，回车全部执行 | 示例：acd）请输入：" extra
    extra=${extra:-'abcd'}
    ##read -p "code.sh 操作（替换或下载选项为 a，修改默认调用日志设置为 b，添加到定时任务为 c，全部不执行为 n，回车全部执行 | 示例：ac）请输入：" code
    ##code=${code:-'abcd'}
    ##read -p "task_before.sh 操作（替换或下载选项为 y，不替换为 n，回车为替换）请输入：" Rbefore
    ##Rbefore=${Rbefore:-'y'}
    read -p "sendNotify.js 操作（替换或下载选项为 y，回车为替换）请输入：" RsendNotify
    RsendNotify=${RsendNotify:-'y'}
    read -p "config.sample.sh 操作（跳过为 0，添加 task:自动更新模板 选项为 1，添加后运行一次为 2，回车等同 2）请输入：" sample
    sample=${sample:-'2'}
fi


# 检查域名连通性
check_url() {
    HTTP_CODE=$(curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $1)
    if [ $HTTP_CODE -eq 200 ]; then
        return 0
    else
        return 1
    fi
}


# 获取有效 config.sh 链接
get_valid_config() {
    config_list=(https://git.metauniverse-cn.com/https://raw.githubusercontent.com/yanyuwangluo/VIP/main/Conf/Qinglong/config.sample.sh)
    for url in ${config_list[@]}; do
        check_url $url
        if [ $? = 0 ]; then
            valid_url=$url
            echo "使用链接 $url"
            break
        fi
    done
}
# 下载 config.sh
dl_config_shell() {
    if [ ! -a "$config_shell_path" ]; then
        touch $config_shell_path
    fi
    curl -sL --connect-timeout 3 $valid_url > $config_shell_path
    cp $config_shell_path $dir_config/config.sh
    # 判断是否下载成功
    config_size=$(ls -l $config_shell_path | awk '{print $5}')
    if (( $(echo "${config_size} < 100" | bc -l) )); then
        echo "config.sh 下载失败"
        exit 0
    fi
}
if [ "${Rconfig}" = 'y' -o "${all}" = 1 ]; then
    get_valid_config && dl_config_shell
else
    echo "已为您跳过替换 config.sh"
fi


# 获取有效 gitfix.sh 链接
get_valid_git() {
    git_list=(https://git.metauniverse-cn.com/https://raw.githubusercontent.com/yanyuwangluo/VIP/main/Scripts/sh/gitfix.sh)
    for url in ${git_list[@]}; do
        check_url $url
        if [ $? = 0 ]; then
            valid_url=$url
            echo "使用链接 $url"
            break
        fi
    done
}

# 下载 gitfix.sh
dl_git_shell() {
    if [ ! -f "$git_shell_path" ]; then
        touch $git_shell_path
    fi
    curl -sL --connect-timeout 3 $valid_url > $git_shell_path
    cp $git_shell_path $dir_config/gitfix.sh
    # 判断是否下载成功
    git_size=$(ls -l $git_shell_path | awk '{print $5}')
    if (( $(echo "${git_size} < 100" | bc -l) )); then
        echo "gitfix.sh 下载失败"
        exit 0
    fi
    # 授权
    chmod 755 $git_shell_path
}

read -p "回车开始执行github连接修复：" Rgit
Rgit=${Rgit:-'y'}

if [ "${Rgit}" = 'y' -o "${all}" = 1 ]; then
    get_valid_git && dl_git_shell
    echo "开始执行拉库修复"
    bash $git_shell_path
else
    echo "已为您跳过操作"
fi



# 获取有效 extra.sh 链接
get_valid_extra() {
    extra_list=(https://git.metauniverse-cn.com/https://raw.githubusercontent.com/yanyuwangluo/VIP/main/Tasks/qlrepo/extra.sh)
    for url in ${extra_list[@]}; do
        check_url $url
        if [ $? = 0 ]; then
            valid_url=$url
            echo "使用链接 $url"
            break
        fi
    done
}
# 下载 extra.sh
dl_extra_shell() {
    if [ ! -a "$extra_shell_path" ]; then
        touch $extra_shell_path
    fi
    curl -sL --connect-timeout 3 $valid_url > $extra_shell_path
    cp $extra_shell_path $dir_config/extra.sh
    # 判断是否下载成功
    extra_size=$(ls -l $extra_shell_path | awk '{print $5}')
    if (( $(echo "${extra_size} < 100" | bc -l) )); then
        echo "extra.sh 下载失败"
        exit 0
    fi
    # 授权
    chmod 755 $extra_shell_path
}
# extra.sh 设置区设置
set_default_extra() {
    echo -e "一、仓库选择\n直接回车拉取Faker2助力池版仓库\n输入3回车拉取Faker3内部互助版仓库\n输入4回车拉取Faker4纯净仓库"
    read -p ": " CollectedRepo
    CollectedRepo=${CollectedRepo:-"2"}  # 如果用户直接回车，则默认为 2
    sed -i "s/CollectedRepo=(2)/CollectedRepo=(${CollectedRepo})/g" $extra_shell_path
}

# 将 ql extra 添加到定时任务
add_ql_extra() {
    if [ "$(grep -c "ql\ extra" /ql/data/config/crontab.list)" != 0 ]; then
        echo "您的任务列表中已存在 task:ql extra"
    else
        echo "开始添加 task:ql extra"
        # 获取token
        token=$(cat /ql/data/config/auth.json | jq --raw-output .token)
        curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"初始化任务","command":"ql extra","schedule":"15 0-23/4 * * *"}' --compressed 'http://127.0.0.1:5600/api/crons?t=1697961933000'
    fi
}
# 运行一次 ql extra
run_ql_extra() {
    ql extra
    sleep 5
}
if [ "${all}" = 1 ]; then
    get_valid_extra && dl_extra_shell && set_default_extra && add_ql_extra && run_ql_extra
elif [ "${extra}" = 'n' ]; then
    echo "已为您跳过操作 extra.sh"
else
    if [[ ${extra} =~ 'a' ]]; then
        get_valid_extra && dl_extra_shell
    fi
    if [[ ${extra} =~ 'b' ]]; then
        set_default_extra
    fi
    if [[ ${extra} =~ 'c' ]]; then
        add_ql_extra
    fi
    if [[ ${extra} =~ 'd' ]]; then
        run_ql_extra
    fi
fi


# 获取有效 sendNotify.js 链接
get_valid_sendNotify() {
    sendNotify_list=(https://git.metauniverse-cn.com/https://raw.githubusercontent.com/shufflewzc/faker2/main/sendNotify.js)  # 替换为实际链接
    for url in ${sendNotify_list[@]}; do
        check_url $url
        if [ $? = 0 ]; then
            valid_url=$url
            echo "使用链接 $url"
            break
        fi
    done
}

# 下载并替换 sendNotify.js
dl_sendNotify_js() {
    if [ ! -a "$sendNotify_js_path" ]; then
        touch $sendNotify_js_path
    fi
    curl -sL --connect-timeout 3 $valid_url > $sendNotify_js_path
    # 判断是否下载成功
    sendNotify_size=$(ls -l $sendNotify_js_path | awk '{print $5}')
    if (( $(echo "${sendNotify_size} < 100" | bc -l) )); then
        echo "sendNotify.js 下载失败"
        exit 0
    fi
    # 替换到 deps 和 scripts 目录
    cp $sendNotify_js_path $sendNotify_deps_path
    cp $sendNotify_js_path $sendNotify_scripts_path
    # 授权
    chmod 755 $sendNotify_js_path $sendNotify_deps_path $sendNotify_scripts_path
    echo "sendNotify.js 已替换"
}

# 调用下载和替换流程
if [ "${RsendNotify}" = 'y' -o "${all}" = 1 ]; then
    get_valid_sendNotify && dl_sendNotify_js
else
    echo "已为您跳过操作 sendNotify.js"
fi


# 添加定时任务 自动更新模板
add_curl_sample() {
    if [ "$(grep -c "config.sample.sh" /ql/data/config/crontab.list)" != 0 ]; then
        echo "您的任务列表中已存在 task:自动更新模板"
    else
        echo "开始添加 task:curl config.sample.sh"
        # 获取token
        token=$(cat /ql/data/config/auth.json | jq --raw-output .token)
        curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"自动更新模板","command":"curl -L https://git.metauniverse-cn.com/https://raw.githubusercontent.com/yanyuwangluo/VIP/main/Conf/Qinglong/config.sample.sh -o /ql/data/sample/config.sample.sh && cp -rf /ql/data/sample/config.sample.sh /ql/config","schedule":"45 6,18 * * *"}' --compressed 'http://127.0.0.1:5600/api/crons?t=1697961933000'
    fi
}
run_curl_sample() {
    curl -sL $valid_url -o /ql/data/sample/config.sample.sh && cp -rf /ql/data/sample/config.sample.sh /ql/data/config
}
if [ "${all}" = 1 ]; then
    get_valid_config && add_curl_sample && run_curl_sample
else
    case ${sample} in
        0)  echo "已为您跳过自动更新模板"
        ;;
        1)  get_valid_config && add_curl_sample
        ;;
        2)  get_valid_config && add_curl_sample && run_curl_sample
    esac    
fi


# 提示配置结束
echo -e "\n配置到此结束，您是否成功了呢？"
