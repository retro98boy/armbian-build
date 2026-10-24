# Rockchip RK3568, RK817, eMMC, RGMII Ethernet, AIC8801 SDIO Wi-Fi and UART Bluetooth.
BOARD_NAME="CLINK-T68"
BOARD_MAINTAINER=""
BOARDFAMILY="rk35xx"
INTRODUCED="2026"
BOOT_SOC="rk3568"
KERNEL_TARGET="current,edge,vendor"
KERNEL_TEST_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3568-clink-t68-p1.dtb"
BOOT_SCENARIO="binman"
IMAGE_PARTITION_TABLE="gpt"
MODULES_VENDOR="panel-simple pwm_bl gpio-fan mc3230"
MODULES_CURRENT="panel-edp pwm_bl mc3230"
MODULES_EDGE="panel-edp pwm_bl mc3230"
PACKAGE_LIST_BOARD="alsa-ucm-conf bluez rfkill"

# The stock SDIO IDs identify AIC8801. Radxa's SDIO driver supports these IDs.
# Use Radxa's paired firmware. Stock firmware equivalence and board operation remain unverified.
enable_extension "radxa-aic8800"
AIC8800_TYPE="sdio"

function post_family_config__clink_t68() {
	declare -g BOOTCONFIG="clink-t68-rk3568_defconfig"
	declare -g BOOTSOURCE="https://github.com/u-boot/u-boot.git"
	declare -g BOOTBRANCH="tag:v2026.07"
	declare -g BOOTPATCHDIR="v2026.07"
	declare -g BOOTDIR="u-boot-${BOARD}"
}

function post_family_tweaks_bsp__clink_t68_audio() {
	install -Dm644 "${SRC}/packages/bsp/clink-t68/bsp-audio/clink-t68.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/clink-t68/clink-t68.conf"
	install -Dm644 "${SRC}/packages/bsp/clink-t68/bsp-audio/clink-t68-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/clink-t68/clink-t68-HiFi.conf"
	mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/clink-t68"
	ln -sfn ../../Rockchip/clink-t68/clink-t68.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/clink-t68/clink-t68.conf"
}
