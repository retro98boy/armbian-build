# Rockchip RK3399 hexa core 4GB SoC eMMC GBE USB3 WiFi/BT
BOARD_NAME="TIANNUO TN3399_V3"
BOARD_VENDOR="rockchip"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="retro98boy"
BOOTCONFIG="tn3399-v3-rk3399_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3399-tn3399-v3.dtb"
BOOTBRANCH_BOARD="tag:v2025.04"
BOOTPATCHDIR="v2025.04"
BOOT_SCENARIO="binman"
SRC_EXTLINUX="yes"
SRC_CMDLINE="console=ttyS2,1500000 console=tty0"
PACKAGE_LIST_BOARD="alsa-ucm-conf"

function post_family_tweaks_bsp__tn3399-v3() {
	display_alert "${BOARD}" "Installing ALSA UCM conf files" "info"

	install -Dm644 $SRC/packages/bsp/rockchip-rt5640/rockchip,rt5640-codec.conf $destination/usr/share/alsa/ucm2/conf.d/simple-card/rockchip,rt5640-codec.conf
	install -Dm644 $SRC/packages/bsp/rockchip-rt5640/rockchip,rt5640-codec-HiFi.conf $destination/usr/share/alsa/ucm2/conf.d/simple-card/rockchip,rt5640-codec-HiFi.conf
}
