#!/bin/bash

# 获取代码
#mkdir friendlywrt-h5
#cd friendlywrt-h5
#repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master -m h5.xml --repo-url=https://github.com/friendlyarm/repo  --no-clone-bundle
#repo sync -c --no-clone-bundle -j8

# 调整wrt代码【非常重要】
#cd friendlywrt-h5
rm -rf friendlywrt
mkdir friendlywrt
cd friendlywrt
git init
git config user.email abc@abc.com
git config user.name abc
git remote add origin https://github.com/friendlyarm/friendlywrt.git
git remote add upstream https://github.com/openwrt/openwrt.git
git pull origin master-v18.06.1
git pull upstream openwrt-18.06 --no-edit

# 融合lede的插件
cd ..
git clone https://github.com/coolsnowwolf/openwrt lede
cd lede
./scripts/feeds update -a
./scripts/feeds install -a
cp -r package/lean/ ../friendlywrt/package/
cd ../friendlywrt/package/lean
rm -rf baidupcs-web
rm -rf luci-app-baidupcs-web
rm -rf luci-theme-netgear
rm -rf luci-theme-argon
rm -rf samba4
rm -rf luci-app-samba4
rm -rf luci-app-docker
rm -rf luci-theme-netgear
rm -rf luci-theme-argon

# 安装feed前代码微调
cd ../../
mv feeds.conf.default feeds.conf.default.bak
touch feeds.conf.default
echo "src-git packages https://git.openwrt.org/feed/packages.git;openwrt-18.06" >>feeds.conf.default
echo "src-git luci https://git.openwrt.org/project/luci.git;openwrt-18.06" >>feeds.conf.default
echo "src-git routing https://git.openwrt.org/feed/routing.git;openwrt-18.06" >>feeds.conf.default
echo "src-git helloworld https://github.com/fw876/helloworld" >>feeds.conf.default
echo "src-git diy1 https://github.com/xiaorouji/openwrt-passwall.git;main" >>feeds.conf.default
echo "src-git OpenClash https://github.com/vernesong/OpenClash.git;master" >>feeds.conf.default
git clone https://github.com/rosywrt/luci-theme-rosy.git package/lean/luci-theme-rosy
git clone https://github.com/Dboykey/CKdiy.git package/CKdiy

# 更新和安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 安装feed后代码微调
mv package/CKdiy/packr feeds/packages/devel/
cp -r ../lede/feeds/packages/libs/nss package/CKdiy/
cp -r ../lede/feeds/packages/libs/nspr package/CKdiy/
cp -r ../lede/feeds/packages/devel/ninja package/CKdiy/
cp -r ../lede/feeds/packages/utils/zstd package/CKdiy/
rm -rf feeds/packages/admin/ipmitool
cp -r package/CKdiy/ipmitool ./feeds/packages/admin/
rm -rf packages/lang/golang
cp -r package/CKdiy/golang ./feeds/packages/lang/
echo -e '\nDboykey Build\n'  >> package/base-files/files/etc/banner
ln -s package/lean/default-settings/files/zzz-default-settings
sed -i '/uci commit luci/i\\uci set luci.main.mediaurlbase=/luci-static/rosy' package/lean/default-settings/files/zzz-default-settings
sed -i -e '/shadow/d' package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci commit network" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.netmask='255.255.255.0'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.ipaddr='192.168.2.1'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\ " package/lean/default-settings/files/zzz-default-settings
sed -i '/exit/i\chown -R root:root /usr/share/netdata/web' package/lean/default-settings/files/zzz-default-settings
cp -r ../lede/feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn feeds/luci/applications/luci-app-advanced-reboot/po/
sed -i 's/高级重启/关机/' feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn/advanced-reboot.po
sed -i '9,12d' feeds/luci/applications/luci-app-diag-core/luasrc/controller/luci_diag.lua

# 重新更新安装feeds
rm -rf staging_dir logs tmp
./scripts/feeds install -a
