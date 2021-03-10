#!/bin/bash
#
##############################
####  第二部分：调整代码  ####
##############################

# 调整 lede 的插件
git clone https://github.com/coolsnowwolf/lede 5.4
cd 5.4
./scripts/feeds update -a

cd ../friendlywrt/
rm -rf package/lean/baidupcs-web
rm -rf package/lean/luci-app-baidupcs-web
rm -rf package/lean/luci-theme-netgear
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/samba4
rm -rf package/lean/luci-app-samba4
rm -rf package/lean/luci-app-docker
rm -rf package/lean/luci-lib-docker 
rm -rf package/lean/luci-app-n2n_v2
rm -rf package/lean/n2n_v2
rm -rf package/lean/luci-app-openvpn-server
rm -rf package/lean/luci-app-qbittorrent
rm -rf package/lean/qBittorrent
rm -rf package/lean/luci-app-softethervpn
rm -rf package/lean/softethervpn5
rm -rf package/lean/luci-app-vsftpd
rm -rf package/lean/vsftpd-alt
rm -rf package/lean/qt5
rm -rf package/lean/luci-app-webadmin
rm -rf package/lean/dns2socks
rm -rf package/lean/ipt2socks
rm -rf package/lean/kcptun
rm -rf package/lean/microsocks
rm -rf package/lean/pdnsd-alt
rm -rf package/lean/shadowsocksr-libev
rm -rf package/lean/simple-obfs
rm -rf package/lean/trojan
rm -rf package/lean/v2ray-plugin
rm -rf package/lean/k3*
rm -rf package/lean/luci-app-ssrserver-python
rm -rf package/lean/luci-app-cifsd

# 更新下载 feed 前代码微调
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
#mkdir ../dl
#ln -s ../dl
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
