# Rockchip RK3568 DDR3 eMMC USB3 GBE HDMI/LVDS/EDP/DSI WiFi6/BT5.2
BOARD_NAME="ZC-3568D"
BOARD_VENDOR="zhuoce"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER="retro98boy"
INTRODUCED="2026"
KERNEL_TARGET="current,edge,vendor"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3568-zc-3568d.dtb"
BOOT_SCENARIO="binman"
BOOT_SOC="rk3568"
IMAGE_PARTITION_TABLE="gpt"

MODULES_CURRENT="panel-rocknix-generic-dsi"
MODULES_EDGE="panel-rocknix-generic-dsi"
MODULES_VENDOR="panel-simple pwm_bl"

PACKAGE_LIST_BOARD="alsa-ucm-conf bluez rfkill"

# Stock Android firmware matches Radxa 5.0+git20260123.5f7be68d-10 byte-for-byte:
# fmacfw.bin, fmacfw_patch.bin, fw_adid_u03.bin,
# fw_patch_u03.bin, fw_patch_table_u03.bin, and aic_userconfig.txt.
# Use these matching files from Radxa instead of board-specific firmware copies.
enable_extension "radxa-aic8800"
AIC8800_TYPE="sdio"
ZC_AIC_DKMS_VERSION="5.0+git20260123.5f7be68d-10"

function post_family_config__zc-3568d() {
	declare -g BOOTCONFIG="zc-3568d-rk3568_defconfig"
	declare -g BOOTSOURCE="https://github.com/u-boot/u-boot.git"
	declare -g BOOTBRANCH="tag:v2026.07"
	declare -g BOOTPATCHDIR="v2026.07"
	declare -g BOOTDIR="u-boot-${BOARD}"
}

function post_family_tweaks_bsp__zc_3568d_aic_dkms_fix() {
	zc_3568d_install_aic_dkms_fix "${destination}"
}

# Install BSP and mainline UCM2 files in every image.
# Each sound card uses a different name and configuration entry.
function post_family_tweaks_bsp__zc_3568d_audio() {
	install -Dm644 "${SRC}/packages/bsp/zc-3568d/mainline-audio/ZC-3568D.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/ZC-3568D/ZC-3568D.conf"
	install -Dm644 "${SRC}/packages/bsp/zc-3568d/mainline-audio/ZC-3568D-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/ZC-3568D/ZC-3568D-HiFi.conf"
	install -Dm644 "${SRC}/packages/bsp/zc-3568d/bsp-audio/zc-3568d.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/zc-3568d/zc-3568d.conf"
	install -Dm644 "${SRC}/packages/bsp/zc-3568d/bsp-audio/zc-3568d-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/zc-3568d/zc-3568d-HiFi.conf"
	mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/"{simple-card,zc-3568d}
	ln -sfn ../../Rockchip/ZC-3568D/ZC-3568D.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/simple-card/ZC-3568D.conf"
	ln -sfn ../../Rockchip/zc-3568d/zc-3568d.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/zc-3568d/zc-3568d.conf"
}

# Apply the high-speed fix during every DKMS build, including kernel upgrades.
function zc_3568d_install_aic_dkms_fix() {
	local target="$1"
	install -Dm644 "${SRC}/packages/bsp/zc-3568d/aic8800-sdio-dkms.conf" \
		"${target}/etc/dkms/aic8800-sdio-${ZC_AIC_DKMS_VERSION}.conf"
	install -Dm644 "${SRC}/packages/bsp/zc-3568d/aic8801-sdio-highspeed.patch" \
		"${target}/usr/share/zc-3568d/aic8801-sdio-highspeed.patch"
}

function pre_install_kernel_debs__zc_3568d_aic_dkms_fix() {
	# Radxa installs before the BSP package, so stage the same files first.
	zc_3568d_install_aic_dkms_fix "${SDCARD}"
}
