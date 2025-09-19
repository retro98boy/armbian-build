# Amlogic S905L-B 1GB RAM 8GB eMMC GBE USB2 RTL8189FTV WiFi
BOARD_NAME="BesTV R3300-L"
BOARDFAMILY="meson-gxl"
BOARD_MAINTAINER=""
BOOTCONFIG="bestv-r3300-l_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
SERIALCON="ttyAML0"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="amlogic/meson-gxl-s905x-bestv-r3300-l.dtb"
PACKAGE_LIST_BOARD="alsa-ucm-conf" # Contain ALSA UCM top-level configuration file

BOOTBRANCH_BOARD="tag:v2025.04"
BOOTPATCHDIR="v2025.04" # This has a patch that adds support for BesTV R3300-L.

function post_family_config__use_repacked_fip() {
	declare -g UBOOT_TARGET_MAP="u-boot.bin"
	unset write_uboot_platform

	function write_uboot_platform() {
		dd if="$1/u-boot.bin" of="$2" bs=512 seek=1 conv=fsync,notrunc 2>&1
	}
}

function post_uboot_custom_postprocess__repack_vendor_fip_with_mainline_uboot() {
	display_alert "${BOARD}" "Repacking vendor FIP with mainline u-boot.bin" "info"

	BLOBS_DIR="${SRC}/cache/sources/amlogic-fip-blobs/bestv-r3300-l"
	EXTRACT_DIR="${BLOBS_DIR}/extract"

	rm -rf "$EXTRACT_DIR"
	mkdir "$EXTRACT_DIR"
	run_host_command_logged gxlimg -e "${BLOBS_DIR}/bootloader.PARTITION" "$EXTRACT_DIR"

	mv u-boot.bin raw-u-boot.bin
	rm -f "${EXTRACT_DIR}/bl33.enc"
	run_host_command_logged gxlimg \
		-t bl3x \
		-c raw-u-boot.bin \
		"${EXTRACT_DIR}/bl33.enc"
	run_host_command_logged gxlimg \
		-t fip \
		--bl2 "${EXTRACT_DIR}/bl2.sign" \
		--bl30 "${EXTRACT_DIR}/bl30.enc" \
		--bl301 "${EXTRACT_DIR}/bl301.enc" \
		--bl31 "${EXTRACT_DIR}/bl31.enc" \
		--bl33 "${EXTRACT_DIR}/bl33.enc" \
		u-boot.bin

	if [ ! -s u-boot.bin ]; then
		display_alert "${BOARD}" "FIP repack produced empty u-boot.bin" "err"
		exit 1
	fi
}
