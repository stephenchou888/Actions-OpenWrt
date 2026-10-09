#!/bin/bash
#
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# ==================== 1. 自定义固件设置 ====================
# 修改默认 IP 为 192.168.50.5（如不需要可注释掉）
sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate


# ==================== 2. 彻底清理冲突组件 ====================
# 彻底清理 gn 与 naiveproxy（避免 GCC 12 的 C++20 报错）
rm -rf feeds/helloworld/gn
rm -rf feeds/helloworld/naiveproxy
sed -i '/CONFIG_PACKAGE_naiveproxy/d' .config 2>/dev/null || true
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_NaiveProxy/d' .config 2>/dev/null || true

# 彻底清理 hysteria（解决本次 go >= 1.25.0 报错）
# 如果你确定必须要用 Hysteria，请注释掉下面两行，并改用下方的 Golang 25.x
rm -rf feeds/helloworld/hysteria
sed -i '/CONFIG_PACKAGE_hysteria/d' .config 2>/dev/null || true
sed -i '/CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Hysteria/d' .config 2>/dev/null || true


# ==================== 3. 升级 Golang 依赖环境 ====================
# 升级 Golang 到 24.x/25.x 现代分支（适配 Passwall/OpenClash 等主流插件）
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang || \
git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang


# ==================== 4. 清理同名插件与配置加速 ====================
# 清理重复的 luci 插件包防冲突
find package/ -type d -name "luci-app-*" | while read -r dir; do
  name=$(basename "$dir")
  [ -d "feeds/luci/applications/$name" ] && rm -rf "feeds/luci/applications/$name"
done

# 启用 ccache 编译缓存加速
sed -i '/CONFIG_CCACHE/d' .config 2>/dev/null || true
echo "CONFIG_CCACHE=y" >> .config
