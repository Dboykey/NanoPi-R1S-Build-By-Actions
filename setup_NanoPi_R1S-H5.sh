#!/bin/bash

# 这个脚本是从下载源码开始，一直到编译前配置选项的全自动控制流程。
# 使用这个脚本前，首先运行部署lede编译环境脚本和运行NanoPi编译环境脚本。
# 忍不住，把后面编译的部分也加到脚本里来了。

# 获取代码
mkdir friendlywrt-h5
cd friendlywrt-h5
repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master -m h5.xml --repo-url=https://github.com/friendlyarm/repo  --no-clone-bundle
repo sync -c --no-clone-bundle -j8

# 调整 wrt 代码【非常重要】
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

# 融合 lede 的插件
cd ..
git clone https://github.com/coolsnowwolf/lede 5.4
cd 5.4
./scripts/feeds update -a
cd ..
git clone https://github.com/coolsnowwolf/openwrt 4.14
cd 4.14
./scripts/feeds update -a
#./scripts/feeds install -a
mv package/lean/ ../friendlywrt/package/
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
rm -rf qt5
rm -rf luci-app-n2n_v2
rm -rf n2n_v2
rm -rf luci-app-openvpn-server
rm -rf luci-app-qbittorrent
rm -rf qBittorrent
rm -rf luci-app-softethervpn
rm -rf softethervpn5
rm -rf luci-app-webadmin
rm -rf luci-lib-docker 
rm -rf luci-proto-bonding
rm -rf luci-app-sfe
rm -rf luci-app-flowoffload
rm -rf luci-app-vsftpd
rm -rf vsftpd-alt

# 安装 feed 前代码调整
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

# 下载更新 feeds
./scripts/feeds update -a
#./scripts/feeds install -a

# 安装 feed 前代码调整
mv package/CKdiy/packr feeds/packages/devel/

#cp -r ../5.4/feeds/packages/libs/nss package/CKdiy/
#cp -r ../5.4/feeds/packages/libs/nspr package/CKdiy/
#cp -r ../5.4/feeds/packages/utils/zstd package/CKdiy/
#cp -r ../5.4/feeds/packages/devel/ninja package/CKdiy/
#cp -r ../5.4/feeds/packages/devel/meson package/CKdiy/
#cp -r ../5.4/feeds/packages/lang/python/python3 package/CKdiy/
#cp -r ../5.4/package/system/ca-certificates package/CKdiy/

mv ../5.4/feeds/packages/libs/nss feeds/packages/libs/
mv ../5.4/feeds/packages/libs/nspr feeds/packages/libs/
mv ../5.4/feeds/packages/utils/zstd feeds/packages/utils/
mv ../5.4/feeds/packages/devel/ninja feeds/packages/devel/
mv ../5.4/feeds/packages/devel/meson feeds/packages/devel/
rm -rf feeds/packages/lang/python/python3
mv ../5.4/feeds/packages/lang/python/python3 feeds/packages/lang/python/python3
rm -rf package/system/ca-certificates
mv ../5.4/package/system/ca-certificates package/system/
rm -rf packages/lang/golang
mv package/CKdiy/golang ./feeds/packages/lang/
rm -rf feeds/packages/admin/ipmitool
mv package/CKdiy/ipmitool ./feeds/packages/admin/

echo -e '\nDboykey Build\n'  >> package/base-files/files/etc/banner
ln -s package/lean/default-settings/files/zzz-default-settings
sed -i '/uci commit luci/i\\uci set luci.main.mediaurlbase=/luci-static/rosy' package/lean/default-settings/files/zzz-default-settings
sed -i -e '/shadow/d' package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci commit network" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.netmask='255.255.255.0'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.ipaddr='192.168.2.1'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\ " package/lean/default-settings/files/zzz-default-settings
sed -i '/exit/i\chown -R root:root /usr/share/netdata/web' package/lean/default-settings/files/zzz-default-settings
mv ../5.4/feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn feeds/luci/applications/luci-app-advanced-reboot/po/
sed -i 's/高级重启/关机/' feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn/advanced-reboot.po
sed -i '9,12d' feeds/luci/applications/luci-app-diag-core/luasrc/controller/luci_diag.lua

# 安装安装 feeds
#rm -rf staging_dir logs tmp
./scripts/feeds install -a

# 第一次编译是只选CUP架构后的快速编译
touch .config
echo "CONFIG_TARGET_sunxi=y" >>.config
echo "CONFIG_TARGET_sunxi_cortexa53=y" >>.config
echo "CONFIG_TARGET_sunxi_cortexa53_DEVICE_sun50i-h5-nanopi-neo-plus2=y" >>.config
echo 'CONFIG_KERNEL_BUILD_USER="Dboykey"' >>.config
echo "CONFIG_LUCI_LANG_en=y" >>.config
echo "CONFIG_LUCI_LANG_zh-cn=y" >>.config
echo "CONFIG_PACKAGE_default-settings=y" >>.config
echo "# CONFIG_PACKAGE_dnsmasq is not set" >>.config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_auth=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_conntrack=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_dhcp=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_dnssec=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_ipset=y" >>.config
echo "CONFIG_PACKAGE_dnsmasq_full_noid=y" >>.config
echo "CONFIG_PACKAGE_kmod-ipt-ipset=y" >>.config
echo "CONFIG_PACKAGE_kmod-nf-conntrack-netlink=y" >>.config
echo "CONFIG_PACKAGE_kmod-nfnetlink=y" >>.config
echo "CONFIG_PACKAGE_libgmp=y" >>.config
echo "CONFIG_PACKAGE_libiwinfo-lua=y" >>.config
echo "CONFIG_PACKAGE_liblua=y" >>.config
echo "CONFIG_PACKAGE_liblucihttp=y" >>.config
echo "CONFIG_PACKAGE_liblucihttp-lua=y" >>.config
echo "CONFIG_PACKAGE_libmnl=y" >>.config
echo "CONFIG_PACKAGE_libnetfilter-conntrack=y" >>.config
echo "CONFIG_PACKAGE_libnettle=y" >>.config
echo "CONFIG_PACKAGE_libnfnetlink=y" >>.config
echo "CONFIG_PACKAGE_libubus-lua=y" >>.config
echo "CONFIG_PACKAGE_lua=y" >>.config
echo "CONFIG_PACKAGE_luci=y" >>.config
echo "CONFIG_PACKAGE_luci-app-firewall=y" >>.config
echo "CONFIG_PACKAGE_luci-base=y" >>.config
echo "CONFIG_PACKAGE_luci-i18n-base-en=y" >>.config
echo "CONFIG_PACKAGE_luci-i18n-base-zh-cn=y" >>.config
echo "CONFIG_PACKAGE_luci-i18n-firewall-en=y" >>.config
echo "CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y" >>.config
echo "CONFIG_PACKAGE_luci-lib-ip=y" >>.config
echo "CONFIG_PACKAGE_luci-lib-jsonc=y" >>.config
echo "CONFIG_PACKAGE_luci-lib-nixio=y" >>.config
echo "CONFIG_PACKAGE_luci-mod-admin-full=y" >>.config
echo "CONFIG_PACKAGE_luci-proto-ipv6=y" >>.config
echo "CONFIG_PACKAGE_luci-proto-ppp=y" >>.config
echo "CONFIG_PACKAGE_luci-theme-bootstrap=y" >>.config
echo "CONFIG_PACKAGE_luci-theme-rosy=y" >>.config
echo "CONFIG_PACKAGE_rpcd=y" >>.config
echo "CONFIG_PACKAGE_rpcd-mod-rrdns=y" >>.config
echo "CONFIG_PACKAGE_uhttpd=y" >>.config
make defconfig
make download -j8 V=s
make V=s

# 第二次编译前为了排错，先编译 luci-base
#make package/feeds/luci/luci-base/compile V=s

# 第二次编译是 make menuconfig 选择好以后的正式编译，
rm .config*
cp config.r1s ./.config
make defconfig
make download -j8 V=s
make V=s

