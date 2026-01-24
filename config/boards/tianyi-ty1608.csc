# Amlogic S905L3-B 1GB RAM 8GB eMMC microSD FE USB2 MT7688RSN WiFi
BOARD_NAME="Tianyi TY1608"
BOARD_VENDOR="amlogic"
BOARDFAMILY="meson-gxl"
BOARD_MAINTAINER="retro98boy"
BOOTCONFIG="tianyi-ty1608_defconfig"
KERNEL_TARGET="current"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
SERIALCON="ttyAML0"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="amlogic/meson-gxl-s905x-tianyi-ty1608.dtb"
ASOUND_STATE="asound.state.tianyi-ty1608"
BOOTBRANCH_BOARD="tag:v2026.01"
BOOTPATCHDIR="v2026.01"

enable_extension "gxlimg"
enable_extension "amlogic-fip-blobs"

function post_family_config__use_repacked_fip() {
	declare -g UBOOT_TARGET_MAP="u-boot.bin"
	unset write_uboot_platform

	function write_uboot_platform() {
		dd if="$1/u-boot.bin" of="$2" bs=512 seek=1 conv=fsync,notrunc 2>&1
	}
}

function post_uboot_custom_postprocess__repack_vendor_fip_with_mainline_uboot() {
	TMP_DIR=$(mktemp -d)
	trap 'rm -rf "$TMP_DIR"' EXIT
	run_host_command_logged dd \
		if="${SRC}/cache/sources/amlogic-fip-blobs/tianyi-ty1608/mmcblk0boot0" \
		of="${TMP_DIR}/fip" \
		bs=512 skip=1 conv=fsync,notrunc

	gxlimg_repack_fip_with_new_uboot "${TMP_DIR}/fip" gxl
}
