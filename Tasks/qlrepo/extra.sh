#!/usr/bin/env bash
## Mod: Build20210825V2
## 添加你需要重启自动执行的任意命令，比如 ql repo
## 安装node依赖使用 pnpm install -g xxx xxx（Build 20210728-002 及以上版本的 code.sh，可忽略）
## 安装python依赖使用 pip3 install xxx（Build 20210728-002 及以上版本的 code.sh，可忽略）


#------ 说明区 ------#
## 1. 拉取仓库
### （1）定时任务→添加定时→命令【ql extra】→定时规则【15 0-23/4 * * *】→运行
### （2）若运行过 1custom 一键脚本，点击运行即可
### （3）推荐配置：如下。自行在设置区填写编号


#------ 设置区 ------#
## 1. 拉取仓库编号设置，默认 Faker2 仓库
CollectedRepo=(2) ##示例：CollectedRepo=(2 4 6)

#------ 编号区 ------#
:<<\EOF
一、集成仓库（Collected Repositories)
2-Faker2
3-Faker3
4-Faker4

EOF

#------ 代码区 ------#
# 🌱拉取仓库
CR2(){
   ql repo https://git.metauniverse-cn.com/https://github.com/shufflewzc/faker2.git "jd_|jx_|gua_|jddj_|jdCookie" "activity|backUp" "^jd[^_]|USER|function|utils|sendNotify|ZooFaker_Necklace.js|JDJRValidator_|sign_graphics_validate|ql|JDSignValidator|magic|depend|h5sts" "main"
}
CR3(){
    ql repo https://git.metauniverse-cn.com/https://github.com/shufflewzc/faker3.git "jd_|jx_|gua_|jddj_|jdCookie" "activity|backUp" "^jd[^_]|USER|function|utils|sendNotify|ZooFaker_Necklace.js|JDJRValidator_|sign_graphics_validate|ql|JDSignValidator|magic|depend|h5sts" "main"
}
CR4(){
    ql repo https://git.metauniverse-cn.com/https://github.com/shufflewzc/faker4.git "jd_|jx_|gua_|jddj_|jdCookie" "activity|backUp" "^jd[^_]|USER|function|utils|sendNotify|ZooFaker_Necklace.js|JDJRValidator_|sign_graphics_validate|ql|JDSignValidator|magic|depend|h5sts" "main"
}


echo "您的选择是 = $CollectedRepo"

for i in ${CollectedRepo[@]}; do
    CR$i
    sleep 10
done
