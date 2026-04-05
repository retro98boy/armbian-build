# Amlogic A311D 4GB RAM 8GB eMMC GBE USB 2.0 PCIe ASM1064
BOARD_NAME="OneThing Cloud OES"
BOARD_VENDOR="onethingcloud"
BOARDFAMILY="meson-g12b"
BOARD_MAINTAINER="retro98boy"
OFFSET="100" # Reserved for the EPT and vendor U-Boot env
BOOTSIZE="256"
BOOTFS_TYPE="fat"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
MODULES_BLACKLIST="simpledrm" # SimpleDRM conflicts with Panfrost on the OneThing Cloud OES
FULL_DESKTOP="no"
SERIALCON="ttyAML0"
BOOT_FDT_FILE="amlogic/meson-g12b-a311d-oes.dtb"
PACKAGE_LIST_BOARD="libubootenv-tool ttyd"

enable_extension "amlogic-fip-blobs"

function post_family_config__onethingcloud-oes() {
	declare -g BOOTSCRIPT="boot-cainiao-xiaoyi-pro.cmd:boot.cmd"
	declare -g UBOOT_TARGET_MAP="DDR_ENC.USB env-autobootcmd reserved-min-ept"

	unset write_uboot_platform
	function write_uboot_platform() {
		dd if="$1/DDR_ENC.USB" of="$2" bs=512 seek=1 conv=fsync,notrunc 2>&1
		dd if="$1/env-autobootcmd" of="$2" bs=1MiB seek=4 conv=fsync,notrunc 2>&1
		dd if="$1/reserved-min-ept" of="$2" bs=1MiB seek=36 conv=fsync,notrunc 2>&1
	}
}

function post_family_tweaks__onethingcloud-oes() {
	display_alert "${BOARD}" "Installing the aml_autoscript to set U-Boot autoboot cmd on first startup" "info"

	install -Dm755 "${SRC}/cache/sources/amlogic-fip-blobs/onethingcloud-oes/aml_autoscript.cmd" "${SDCARD}/boot/aml_autoscript.cmd"
	install -Dm755 "${SRC}/cache/sources/amlogic-fip-blobs/onethingcloud-oes/aml_autoscript" "${SDCARD}/boot/aml_autoscript" # Vendor U-Boot will try to load it

	display_alert "${BOARD}" "Installing U-Boot env setting" "info"

	cat <<- EOF > "${SDCARD}/etc/fw_env.config"
		# stock EPT
		# /dev/mmcblk1 0x27400000 0x10000 0x27410000 0x10000
		# min EPT
		/dev/mmcblk1 0x400000 0x10000 0x410000 0x10000
	EOF

	display_alert "${BOARD}" "Setting TTYD" "info"

	cat <<- EOF > "${SDCARD}/etc/default/ttyd"
		TTYD_OPTIONS="-W -p 7681 -O login"
	EOF

	display_alert "${BOARD}" "Warning messages output when executing armbian-install" "info"

	echo "" > "${SDCARD}/usr/bin/armbian-install"
	cat <<- EOF > "${SDCARD}/usr/bin/armbian-install"
		#!/bin/sh
		cat <<- TEXT
			It looks like you are trying to install Armbian to eMMC,
			but you are using the wrong method.
			The correct way is to use the dd command to write Armbian.img directly to the eMMC.
			For more detail, refer here:
			https://github.com/retro98boy/onethingcloud-oes-linux
		TEXT
	EOF
}

function build_custom_uboot__onethingcloud-oes() {
	display_alert "${BOARD}" "Use vendor U-Boot binary with Secure Boot enabled" "info"

	cp "${SRC}/cache/sources/amlogic-fip-blobs/onethingcloud-oes/DDR_ENC.USB" .
	cp "${SRC}/cache/sources/amlogic-fip-blobs/onethingcloud-oes/env-autobootcmd" .
	cp "${SRC}/cache/sources/amlogic-fip-blobs/onethingcloud-oes/reserved-min-ept" .

	loop_over_uboot_targets_and_do deploy_built_uboot_bins_for_one_target_to_packaging_area
	declare -g EXTENSION_BUILT_UBOOT=yes
}
