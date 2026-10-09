#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# ==================== 1. 自定义固件设置 ====================
# 修改默认管理 IP（根据你的需求修改，如改为 192.168.50.5 或 192.168.2.1）
sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# 修改主机名（显示在终端和概览页的名称）
sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 修改默认主题为 argon（需确保 .config 或 feeds 中已勾选 luci-theme-argon）
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# ==================== 2. 编译报错修复与环境增强 ====================
# 修复 feeds/helloworld/gn 在 GCC 12 下的 C++20 ranges 编译冲突
rm -rf feeds/helloworld/gn
git clone --depth 1 https://github.com/openwrt/packages.git -b master temp-packages
cp -r temp-packages/devel/gn feeds/helloworld/gn
rm -rf temp-packages

# 升级 Golang 到 23.x（适配新版 Passwall/OpenClash 等插件）
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# 清理重复的 luci 插件包防冲突
find package/ -type d -name "luci-app-*" | while read -r dir; do
  name=$(basename "$dir")
  [ -d "feeds/luci/applications/$name" ] && rm -rf "feeds/luci/applications/$name"
done

# 启用 ccache 编译缓存加速
sed -i '/CONFIG_CCACHE/d' .config 2>/dev/null || true
echo "CONFIG_CCACHE=y" >> .config
