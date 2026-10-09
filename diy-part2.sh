#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 1. 修复 feeds/helloworld/gn 在 GCC 12 下的 C++20 ranges 编译冲突（解决原报错）
rm -rf feeds/helloworld/gn
git clone --depth 1 https://github.com/openwrt/packages.git -b master temp-packages
cp -r temp-packages/devel/gn feeds/helloworld/gn
rm -rf temp-packages

# 2. 自动升级 Golang 依赖版本（防止 Passwall / OpenClash 等插件因 Go 版本过旧报错）
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# 3. 过滤并清理重复插件包（防止 package 与 feeds 冲突）
find package/ -type d -name "luci-app-*" | while read -r dir; do
  name=$(basename "$dir")
  [ -d "feeds/luci/applications/$name" ] && rm -rf "feeds/luci/applications/$name"
done

# 4. 强制启用 ccache 编译加速
sed -i '/CONFIG_CCACHE/d' .config 2>/dev/null || true
echo "CONFIG_CCACHE=y" >> .config
