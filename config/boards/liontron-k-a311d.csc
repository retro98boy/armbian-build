# Amlogic A311D 4GB RAM 32 eMMC GBE USB3 AP6255 WiFi/BT
BOARD_NAME="LIONTRON K-A311D"
BOARDFAMILY="meson-g12b"
BOARD_MAINTAINER=""
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

BOOTBRANCH_BOARD="tag:v2025.04"
BOOTPATCHDIR="v2025.04" # This has a patch that adds support for LIONTRON K-A311D.

function post_family_config__use_repacked_fip() {
	declare -g UBOOT_TARGET_MAP="u-boot.bin"
	unset write_uboot_platform

	function write_uboot_platform() {
		dd if="$1/u-boot.bin" of="$2" bs=512 seek=1 conv=fsync,notrunc 2>&1
	}
}

function post_uboot_custom_postprocess__repack_vendor_fip_with_mainline_uboot() {
	display_alert "${BOARD}" "Repacking vendor FIP with mainline u-boot.bin" "info"

	BLOBS_DIR="${SRC}/cache/sources/amlogic-fip-blobs/liontron-k-a311d"
	EXTRACT_DIR="${BLOBS_DIR}/extract"

	rm -rf "$EXTRACT_DIR"
	mkdir "$EXTRACT_DIR"
	run_host_command_logged dd if="${BLOBS_DIR}/mmcblk0boot0" of="${EXTRACT_DIR}/fip" \
		bs=512 skip=1 conv=fsync,notrunc
	run_host_command_logged gxlimg -e "${EXTRACT_DIR}/fip" "$EXTRACT_DIR"

	mv u-boot.bin raw-u-boot.bin
	rm -f "${EXTRACT_DIR}/bl33.enc"
	run_host_command_logged gxlimg \
		-t bl3x \
		-s raw-u-boot.bin \
		"${EXTRACT_DIR}/bl33.enc"
	run_host_command_logged gxlimg \
		-t fip \
		--bl2 "${EXTRACT_DIR}/bl2.sign" \
		--ddrfw "${EXTRACT_DIR}/ddr4_1d.fw" \
		--ddrfw "${EXTRACT_DIR}/ddr4_2d.fw" \
		--ddrfw "${EXTRACT_DIR}/ddr3_1d.fw" \
		--ddrfw "${EXTRACT_DIR}/piei.fw" \
		--ddrfw "${EXTRACT_DIR}/lpddr4_1d.fw" \
		--ddrfw "${EXTRACT_DIR}/lpddr4_2d.fw" \
		--ddrfw "${EXTRACT_DIR}/diag_lpddr4.fw" \
		--ddrfw "${EXTRACT_DIR}/aml_ddr.fw" \
		--ddrfw "${EXTRACT_DIR}/lpddr3_1d.fw" \
		--bl30 "${EXTRACT_DIR}/bl30.enc" \
		--bl31 "${EXTRACT_DIR}/bl31.enc" \
		--bl33 "${EXTRACT_DIR}/bl33.enc" \
		--rev v3 u-boot.bin

	if [ ! -s u-boot.bin ]; then
		display_alert "${BOARD}" "FIP repack produced empty u-boot.bin" "err"
		exit 1
	fi
}
