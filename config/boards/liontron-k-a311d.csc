# Amlogic A311D 4GB RAM 32GB eMMC GBE USB3 AP6255 WiFi/BT
BOARD_NAME="LIONTRON K-A311D"
BOARD_VENDOR="amlogic"
BOARDFAMILY="meson-g12b"
BOARD_MAINTAINER="retro98boy"
BOOTCONFIG="liontron-k-a311d_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
MODULES_CURRENT="panel-simple-dsi"
MODULES_EDGE="panel-simple-dsi"
MODULES_BLACKLIST="simpledrm" # SimpleDRM conflicts with Panfrost on the LIONTRON K-A311D
FULL_DESKTOP="yes"
SERIALCON="ttyAML0"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="amlogic/meson-g12b-liontron-k-a311d.dtb"
PACKAGE_LIST_BOARD="alsa-ucm-conf" # Contain ALSA UCM top-level configuration file
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
		if="${SRC}/cache/sources/amlogic-fip-blobs/liontron-k-a311d/mmcblk0boot0" \
		of="${TMP_DIR}/fip" \
		bs=512 skip=1 conv=fsync,notrunc

	gxlimg_repack_fip_with_new_uboot "${TMP_DIR}/fip" g12b
}
