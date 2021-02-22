#!/bin/bash

echo -e '\nDboykey Build\n'  >> package/base-files/files/etc/banner
sed -i '/uci commit luci/i\\uci set luci.main.mediaurlbase=/luci-static/argon' package/lean/default-settings/files/zzz-default-settings
sed -i -e '/shadow/d' package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci commit network" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.netmask='255.255.255.0'" package/lean/default-settings/files/zzz-default-settings
sed -i "/uci commit luci/a\\uci set network.lan.ipaddr='192.168.2.1'" package/lean/default-settings/files/zzz-default-setting
sed -i "/uci commit luci/a\\ " package/lean/default-settings/files/zzz-default-settings
sed -i '/exit/i\mv /etc/rc.d/S25dockerd /etc/rc.d/S92dockerd && sed -i "s/START=25/START=92/g" S92dockerd' package/lean/default-settings/files/zzz-default-settings
sed -i '/uci commit luci/i\uci set luci.main.mediaurlbase="/luci-static/argon"' package/lean/default-settings/files/zzz-default-settings
sed -i '/exit/i\chown -R root:root /usr/share/netdata/web' package/lean/default-settings/files/zzz-default-settings
sed -i 's/option fullcone\t1/option fullcone\t0/' package/network/config/firewall/files/firewall.config
sed -i '/8.8.8.8/d' package/base-files/files/root/setup.sh
sed -i '/Load Average/i\<tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%></td></tr>' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
sed -i 's/pcdata(boardinfo.system or "?")/"ARMv8"/' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
sed -i 's/高级重启/关机/' feeds/luci/applications/luci-app-advanced-reboot/po/zh-cn/advanced-reboot.po
sed -i '9,12d' feeds/luci/applications/luci-app-diag-core/luasrc/controller/luci_diag.lua
