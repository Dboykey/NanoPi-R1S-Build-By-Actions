#!/bin/bash

mv feeds.conf.default feeds.conf.default.bak
touch feeds.conf.default
echo "src-git packages https://github.com/coolsnowwolf/packages" >>feeds.conf.default
echo "src-git luci https://github.com/coolsnowwolf/luci" >>feeds.conf.default
echo "src-git routing https://git.openwrt.org/feed/routing.git" >>feeds.conf.default
echo "src-git helloworld https://github.com/fw876/helloworld" >>feeds.conf.default
echo "src-git OpenClash https://github.com/vernesong/OpenClash.git;master" >>feeds.conf.default
echo "src-git lienol https://github.com/Lienol/openwrt-package.git;main" >>feeds.conf.default
echo "src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main" >>feeds.conf.default
echo "src-git adockerman https://github.com/lisaac/luci-app-dockerman" >>feeds.conf.default
echo "src-git ldockerman https://github.com/lisaac/luci-lib-docker" >>feeds.conf.default
echo "src-git CKdiy https://github.com/Dboykey/CKdiy" >>feeds.conf.default

git clone https://github.com/rosywrt/luci-theme-rosy.git package/lean/luci-theme-rosy
git clone https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr
git clone https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon

./scripts/feeds update -a && ./scripts/feeds install -a
