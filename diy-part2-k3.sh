#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
#sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate

# 删除自带 golang
rm -rf feeds/packages/lang/golang
# 拉取 golang
git clone https://github.com/sbwml/packages_lang_golang.git -b 24.x feeds/packages/lang/golang

# 删除自带 autosamba
rm -rf feeds/public/autosamba
rm -rf package/public/autosamba

# 删除自带 v2ray-geodata
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/v2ray-geodata

# 删除自带 xray-core
rm -rf feeds/packages/net/xray-core
rm -rf package/feeds/packages/xray-core

# 拉取 passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall/packages
#cd package/passwall/packages
#git checkout fed70a5113b60c96d9c8182e40770f37c83d67ba
#cd -

# 拉取 luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall.git package/passwall/luci
#cd package/passwall/luci
#git checkout ebd3355bdf2fcaa9e0c43ec0704a8d9d8cf9f658
#cd -

# 拉取 ShadowSocksR Plus+
#git clone https://github.com/fw876/helloworld.git -b master package/helloworld

# 拉取锐捷认证
git clone https://github.com/sbwml/luci-app-mentohust package/mentohust

# 拉取 easytier、luci-app-easytier
git clone https://github.com/EasyTier/luci-app-easytier.git package/easytier

# 拉取 msd_lite、luci-app-msd_lite
git clone https://github.com/gtolog/openwrt-msd_lite.git package/msd_lite
#git clone https://github.com/gw826943555/openwrt_msd_lite.git package/msd_lite

# 拉取 OpenAppFilter、luci-app-oaf
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 拉取 luci-theme-argon
#git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci/luci-theme-argon

# 删除自带 ddns-scripts
rm -rf feeds/packages/net/ddns-scripts
# 删除自带 dnsmasq
rm -rf package/network/services/dnsmasq
# 删除自带 tailscale
#rm -rf feeds/packages/net/tailscale
# 删除 passwall-packages 中 hysteria
#rm -rf package/passwall/packages/hysteria
# 删除 passwall-packages 中 naiveproxy
#rm -rf package/passwall/packages/naiveproxy

# 筛选程序
function merge_package(){
    # 参数1是分支名,参数2是库地址。所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}
# 提取 ddns-scripts
merge_package openwrt-23.05 https://github.com/immortalwrt/packages.git feeds/packages/net net/ddns-scripts
# 提取 dnsmasq
merge_package openwrt-23.05 https://github.com/immortalwrt/packages.git package/network/services package/network/services/dnsmasq
# 提取 tailscale
#merge_package openwrt-23.05 https://github.com/immortalwrt/packages.git feeds/packages/net net/tailscale
# 提取 luci-theme-argon
merge_package openwrt-23.05 https://github.com/sbwml/luci-theme-argon.git package/luci luci-theme-argon
# 提取 hysteria
#merge_package v5 https://github.com/sbwml/openwrt_helloworld.git package/passwall/packages hysteria
# 提取 naiveproxy
#merge_package v5 https://github.com/sbwml/openwrt_helloworld.git package/passwall/packages naiveproxy
#merge_package master https://github.com/kenzok8/small.git package/passwall/packages naiveproxy
#merge_package master https://github.com/immortalwrt/packages.git package/passwall/packages net/naiveproxy
# 提取 pdnsd-alt、upx
merge_package main https://github.com/kenzok8/small-package.git package/small-package pdnsd-alt upx
