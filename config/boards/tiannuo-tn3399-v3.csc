# Rockchip RK3399 4GB DDR3 16GB eMMC GBE USB3 AP6255 WiFi/BT
BOARD_NAME="TIANNUO TN3399_V3"
BOARD_VENDOR="tiannuo"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="retro98boy"
BOOTCONFIG="tn3399-v3-rk3399_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3399-tn3399-v3.dtb"
BOOTBRANCH_BOARD="tag:v2026.01"
BOOTPATCHDIR="v2026.01"
BOOT_SCENARIO="binman"
SRC_EXTLINUX="yes"
SRC_CMDLINE="console=ttyS2,1500000 console=tty0"
PACKAGE_LIST_BOARD="alsa-ucm-conf"

function post_family_tweaks_bsp__tn3399-v3() {
	display_alert "${BOARD}" "Installing ALSA UCM conf files" "info"

	install -Dm644 "${SRC}/packages/bsp/tiannuo-tn3399-v3/tn3399-v3.conf" \
		"${destination}/usr/share/alsa/ucm2/conf.d/simple-card/tn3399-v3.conf"
	install -Dm644 "${SRC}/packages/bsp/tiannuo-tn3399-v3/tn3399-v3-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/conf.d/simple-card/tn3399-v3-HiFi.conf"
}
