#!/bin/bash
# Description: OpenWrt DIY script part 2 (After Update feeds)

# 1. 升级 Golang 到 24.x（构建现代 sing-box/xray 所需的底层环境）
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 2. 避免插件命名冲突（若官方源与你的插件库有同名包，优先使用你的插件库）
for pkg in $(ls feeds/custompkgs/ 2>/dev/null); do
  [ -d "feeds/luci/applications/$pkg" ] && rm -rf "feeds/luci/applications/$pkg"
  [ -d "feeds/packages/net/$pkg" ] && rm -rf "feeds/packages/net/$pkg"
done

# 3. 自定义固件后台 IP（如需默认 192.168.1.1，请在下方命令前加 # 注释）
sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# 4. 开启 ccache 编译加速
sed -i '/CONFIG_CCACHE/d' .config 2>/dev/null || true
echo "CONFIG_CCACHE=y" >> .config

# 5. 修复 dnsmasq 与 dnsmasq-full 文件冲突，确保 passwall 只使用 dnsmasq-full
sed -i '/CONFIG_PACKAGE_dnsmasq/d;/CONFIG_PACKAGE_dnsmasq-full/d' .config 2>/dev/null || true
echo "CONFIG_PACKAGE_dnsmasq=n" >> .config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >> .config
