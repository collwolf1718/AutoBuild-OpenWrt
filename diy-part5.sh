#!/bin/bash
#=================================================
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#=================================================

# 修改默认IP
sed -i 's/192.168.1.1/192.168.110.1/g' package/base-files/files/bin/config_generate
# 修改网关
sed -i 's/192.168.$((addr_offset++)).1/192.168.$((addr_offset++)).1/g' package/base-files/files/bin/config_generate

# 修改主机名称
### sed -i 's/OpenWrt/Yuos/g' package/base-files/files/bin/config_generate##

# 修改版本号
### sed -i "s/OpenWrt/小渔学长 build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" package/default-settings/files/zzz-default-settings##


# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_USER="MOLUN"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_USER=\).*@\1$"MOLUN"@' .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
    echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
    sed -i 's@\(CONFIG_KERNEL_BUILD_DOMAIN=\).*@\1$"GitHub Actions"@' .config

# 添加5.4内核ACC、shortcut-fe补丁
# openwrt21.02 netfilter补丁\
cp -rf $GITHUB_WORKSPACE/patchs/firewall/* package/firmware/
patch -p1 < package/firmware/001-fix-firewall-flock.patch
# 打补丁
wget -O package/firmware/xt_FULLCONENAT.c https://raw.githubusercontent.com/Chion82/netfilter-full-cone-nat/master/xt_FULLCONENAT.c
cp -rf package/firmware/xt_FULLCONENAT.c package/nftables/include/linux/netfilter/xt_FULLCONENAT.c
cp -rf package/firmware/xt_FULLCONENAT.c package/libnftnl/include/linux/netfilter/xt_FULLCONENAT.c
cp -rf package/firmware/xt_FULLCONENAT.c package/libs/libnetfilter-conntrack/xt_FULLCONENAT.c
