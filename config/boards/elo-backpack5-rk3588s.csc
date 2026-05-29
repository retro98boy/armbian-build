# Rockchip RK3588s 4GB LPDDR5 64GB eMMC HDMI USB3 AP6276P WiFi/BT
BOARD_NAME="Elo Backpack5 RK3588S"
BOARD_VENDOR="elo"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER="retro98boy"
INTRODUCED="2026"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3588s-elo-backpack5.dtb"
BOOT_SCENARIO="tpl-blob-atf-mainline" # Mainline ATF
BOOT_SOC="rk3588"
IMAGE_PARTITION_TABLE="gpt"

function post_family_config__elo-backpack5-rk3588s() {
	display_alert "$BOARD" "mainline u-boot overrides" "info"

	declare -g BOOTCONFIG="elo-backpack5-rk3588s_defconfig"
	declare -g BOOTDELAY=1
	declare -g BOOTSOURCE="https://github.com/u-boot/u-boot.git"
	declare -g BOOTBRANCH="tag:v2026.01"
	declare -g BOOTPATCHDIR="v2026.01"
	declare -g BOOTDIR="u-boot-${BOARD}"

	declare -g UBOOT_TARGET_MAP="BL31=bl31.elf ROCKCHIP_TPL=${RKBIN_DIR}/${DDR_BLOB};;u-boot-rockchip.bin"
	unset uboot_custom_postprocess write_uboot_platform write_uboot_platform_mtd

	function write_uboot_platform() {
		dd "if=$1/u-boot-rockchip.bin" "of=$2" bs=32k seek=1 conv=notrunc status=none
	}
}
