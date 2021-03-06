#!/bin/bash
#
################################
####  这个是 All in 1 脚本  ####
################################

# 环境部署
sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
sudo -E apt-get -qq update
sudo -E apt-get -qq install $(curl -fsSL git.io/depends-ubuntu-1804)
sudo -E apt-get -qq autoremove --purge
sudo -E apt-get -qq clean
sudo timedatectl set-timezone "$TZ"
sudo apt-get -y install bc libtinfo5 build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev
sudo apt-get -y install unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib autopoint
sudo apt-get -y install msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool
sudo apt-get -y install device-tree-compiler gcc-aarch64-linux-gnu patch p7zip p7zip-full
sudo apt-get -y install curl ne screen htop libxcb-ewmh-dev parted dosfstools
wget -O - https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh | bash

# 安装 Repo
git clone https://github.com/friendlyarm/repo
sudo cp repo/repo /usr/bin/

# 下载 friendlywrt-h5 源码
mkdir h5
cd h5
repo init -u https://github.com/friendlyarm/friendlywrt_manifests -b master -m h5.xml --repo-url=https://github.com/friendlyarm/repo  --no-clone-bundle
repo sync -c --no-clone-bundle -j8

# 替换 wrt 代码为 lede 版
rm -rf friendlywrt
mkdir friendlywrt
git clone https://github.com/coolsnowwolf/openwrt friendlywrt

# 调整 lede 的插件
git clone https://github.com/coolsnowwolf/lede 5.4
cd 5.4
./scripts/feeds update -a

cd ../friendlywrt/package/lean
rm -rf baidupcs-web
rm -rf luci-app-baidupcs-web
rm -rf luci-theme-netgear
rm -rf luci-theme-argon
rm -rf samba4
rm -rf luci-app-samba4
rm -rf luci-app-docker
rm -rf luci-lib-docker 
rm -rf luci-app-n2n_v2
rm -rf n2n_v2
rm -rf luci-app-openvpn-server
rm -rf luci-app-qbittorrent
rm -rf qBittorrent
rm -rf luci-app-softethervpn
rm -rf softethervpn5
rm -rf luci-app-vsftpd
rm -rf vsftpd-alt
rm -rf qt5
rm -rf luci-app-webadmin
rm -rf dns2socks
rm -rf ipt2socks
rm -rf kcptun
rm -rf microsocks
rm -rf pdnsd-alt
rm -rf shadowsocksr-libev
rm -rf simple-obfs
rm -rf trojan
rm -rf v2ray-plugin
rm -rf k3*
rm -rf luci-app-ssrserver-python
rm -rf luci-app-cifsd

# 更新下载 feed 前代码微调
cd ../../
cp feeds.conf.default feeds.conf.default.bak
sed -i -e '/helloworld/d' feeds.conf.default
sed -i -e '/#/d' feeds.conf.default
git clone https://github.com/Dboykey/CKdiy.git package/CKdiy
git clone https://github.com/xiaorouji/openwrt-passwall.git package/passwall
git clone -b master https://github.com/vernesong/OpenClash.git ../add/OpenClash
cp -r ../add/OpenClash/luci-app-openclash ./package/lean/
git clone https://github.com/rosywrt/luci-theme-rosy.git ../add/Rosy
cp -r ../add/Rosy/luci-theme-rosy ./package/lean/
git clone https://github.com/linkease/ddnsto-openwrt.git ../add/ddnsto
cp -r ../add/ddnsto/luci-app-ddnsto ./package/lean/
cp -r ../add/ddnsto/ddnsto ./package/network/services/

# 更新下载 feeds
./scripts/feeds update -a

# 安装 feed 前代码微调
mv package/CKdiy/packr feeds/packages/devel/

rm -rf feeds/packages/lang/golang
cp -r ../5.4/feeds/packages/lang/golang ./feeds/packages/lang/
rm -rf feeds/packages/admin/ipmitool
cp -r ../5.4/feeds/packages/admin/ipmitool ./feeds/packages/admin/

echo -e '\nDboykey Build\n'  >> package/base-files/files/etc/banner
ln -s package/lean/default-settings/files/zzz-default-settings
mkdir ../dl
ln -s ../dl
sed -i '/uci commit luci/i\\uci set luci.main.mediaurlbase=/luci-static/rosy' package/lean/default-settings/files/zzz-default-settings
sed -i -e '/shadow/d' package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci commit network" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.netmask='255.255.255.0'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.ipaddr='192.168.2.1'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\ " package/lean/default-settings/files/zzz-default-settings
sed -i '/exit/i\chown -R root:root /usr/share/netdata/web' package/lean/default-settings/files/zzz-default-settings
cp -r ../5.4/feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn feeds/luci/applications/luci-app-advanced-reboot/po/
sed -i 's/高级重启/关机/' feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn/advanced-reboot.po
sed -i 's/双分区启动切换/关机/' package/lean/default-settings/i18n/more.zh-cn.po
sed -i '9,12d' feeds/luci/applications/luci-app-diag-core/luasrc/controller/luci_diag.lua

cp feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm.bak
sed -i '/Load Average/i\<tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%></td></tr>' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
sed -i 's/pcdata(boardinfo.system or "?")/"ARMv8"/' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

# 安装 feeds
./scripts/feeds install -a

# 编译 OpenWrt
#cp ../../config.lede ./.config
cp ../../$CONFIG_FILE ./.config
make defconfig
make download
make tools/compile
make toolchain/compile
make package/feeds/luci/luci-base/compile

cp dl/naiveproxy-88.0.4324.96-1.tar.gz build_dir/target-aarch64_cortex-a53_musl/
cd ./build_dir/target-aarch64_cortex-a53_musl/
tar zxvf naiveproxy-88.0.4324.96-1.tar.gz
rm naiveproxy-88.0.4324.96-1.tar.gz
cd ../../
sed -i "s|sys/random.h|/usr/include/linux/random.h|g" build_dir/target-aarch64_cortex-a53_musl/naiveproxy-88.0.4324.96-1/src/base/rand_util_posix.cc

make -j3

# 生成 SD 镜像
## 删除重复编译wrt的步骤
cp scripts/build.sh scripts/build.sh.bak
sed -i '130,150 {/build_friendlywrt/d}' scripts/build.sh
sed -i '297c\\               rm -f F*.gz' scripts/build.sh
sed -i '298c\\               gzip -9 F*.img' scripts/build.sh

## 修改代码让其支持使用其他的wrt源码而不是特定的那套
sed -i 's/root-allwinner-h5/root-sunxi/' device/friendlyelec/h5/base.mk

# 正式生成SD镜像
./build.sh nanopi_r1s.mk
