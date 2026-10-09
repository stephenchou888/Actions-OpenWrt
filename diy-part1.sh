#!/bin/bash
# Description: OpenWrt DIY script part 1 (Before Update feeds)

# 1. 添加依赖库 (small)
echo 'src-git small https://github.com/stephenchou888/small' >> feeds.conf.default

# 2. 添加插件库 (openwrt-packages)
echo 'src-git custompkgs https://github.com/stephenchou888/openwrt-packages' >> feeds.conf.default
