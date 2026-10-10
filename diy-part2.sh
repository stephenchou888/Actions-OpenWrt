#!/bin/bash
# Description: OpenWrt DIY script part 2 (After Update feeds)

# 1. 升级 Golang 到 24.x
rm -rf feeds/packages/lang/golang
if [ ! -d feeds/packages/lang/golang ]; then
  git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
fi

# 2. 清理冲突组件
for pkg in luci-app-passwall luci-app-passwall2 luci-theme-argon luci-theme-alpha luci-theme-ifit luci-theme-tomato luci-theme-atmaterial_new luci-app-smartdns luci-app-openclash luci-app-ssr-plus; do
  [ -d "feeds/luci/applications/$pkg" ] && rm -rf "feeds/luci/applications/$pkg"
  [ -d "feeds/packages/net/$pkg" ] && rm -rf "feeds/packages/net/$pkg"
  [ -d "feeds/packages/lang/$pkg" ] && rm -rf "feeds/packages/lang/$pkg"
done

# 3. 清空旧配置，避免遗留冲突项
sed -i '/CONFIG_PACKAGE_dnsmasq/d;/CONFIG_PACKAGE_dnsmasq-full/d;/CONFIG_PACKAGE_luci-app-passwall/d;/CONFIG_PACKAGE_luci-app-passwall2/d;/CONFIG_PACKAGE_luci-theme-argon/d;/CONFIG_PACKAGE_luci-app-smartdns/d;/CONFIG_PACKAGE_luci-theme-alpha/d;/CONFIG_PACKAGE_luci-theme-ifit/d;/CONFIG_PACKAGE_luci-theme-tomato/d;/CONFIG_PACKAGE_luci-theme-atmaterial_new/d' .config 2>/dev/null || true

echo "CONFIG_PACKAGE_dnsmasq=n" >> .config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >> .config

echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_mosdns=y" >> .config

echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-material3=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-glass=y" >> .config

# 4. 自定义后台 IP
sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# 5. 开启 ccache
sed -i '/CONFIG_CCACHE/d' .config 2>/dev/null || true
echo "CONFIG_CCACHE=y" >> .config
