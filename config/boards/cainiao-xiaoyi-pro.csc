# Amlogic A311D 4GB RAM 32GB eMMC HDMI GBE USB 2.0
BOARD_NAME="CAINIAO XiaoYi Pro"
BOARD_VENDOR="cainiao"
BOARDFAMILY="meson-g12b"
BOARD_MAINTAINER="retro98boy"
OFFSET="100" # Reserved for the EPT and vendor U-Boot env
BOOTSIZE="256"
BOOTFS_TYPE="fat"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
MODULES_BLACKLIST="simpledrm" # SimpleDRM conflicts with Panfrost on the CAINIAO XiaoYi Pro
FULL_DESKTOP="yes"
SERIALCON="ttyAML0"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="amlogic/meson-g12b-a311d-cainiao-xiaoyi-pro.dtb"
PACKAGE_LIST_BOARD="alsa-ucm-conf libubootenv-tool" # Contain ALSA UCM top-level configuration file

enable_extension "amlogic-fip-blobs"

function post_family_config__cainiao-xiaoyi-pro() {
	declare -g BOOTSCRIPT="boot-cainiao-xiaoyi-pro.cmd:boot.cmd"
	declare -g UBOOT_TARGET_MAP="DDR_ENC.USB env-autobootcmd reserved-min-ept"

	unset write_uboot_platform
	function write_uboot_platform() {
		dd if="$1/DDR_ENC.USB" of="$2" bs=512 seek=1 conv=fsync,notrunc 2>&1
		dd if="$1/env-autobootcmd" of="$2" bs=1MiB seek=4 conv=fsync,notrunc 2>&1
		dd if="$1/reserved-min-ept" of="$2" bs=1MiB seek=36 conv=fsync,notrunc 2>&1
	}
}

function post_family_tweaks__cainiao-xiaoyi-pro() {
	display_alert "${BOARD}" "Installing the aml_autoscript to set U-Boot autoboot cmd on first startup" "info"

	install -Dm755 "${SRC}/cache/sources/amlogic-fip-blobs/cainiao-xiaoyi-pro/aml_autoscript.cmd" "${SDCARD}/boot/aml_autoscript.cmd"
	install -Dm755 "${SRC}/cache/sources/amlogic-fip-blobs/cainiao-xiaoyi-pro/aml_autoscript" "${SDCARD}/boot/aml_autoscript" # Vendor U-Boot will try to load it
	install -Dm755 "${SRC}/cache/sources/amlogic-fip-blobs/cainiao-xiaoyi-pro/u-boot.bin.ext" "${SDCARD}/boot/u-boot.bin.ext" # mainline U-Boot for chainload

	display_alert "${BOARD}" "Installing U-Boot env setting" "info"

	cat <<- EOF > "${SDCARD}/etc/fw_env.config"
		# stock EPT
		# /dev/mmcblk1 0x4d400000 0x10000
		# min EPT
		/dev/mmcblk1 0x400000 0x10000
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
			https://github.com/retro98boy/amlogic-devices/tree/main/devices/cainiao-xiaoyi-pro
		TEXT
	EOF
}

function post_family_tweaks_bsp__cainiao-xiaoyi-pro() {
	# Similar to CAINIAO CNIoT-CORE
	display_alert "${BOARD}" "Installing ALSA UCM configuration files" "info"

	# Use ALSA UCM via CLI:
	# alsactl init hw:cniotcore && alsaucm -c hw:cniotcore set _verb "HiFi" set _enadev "HDMI" set _enadev "Speaker"
	# aplay -D plughw:cniotcore,0 path-to-hdmi-sound.wav
	# aplay -D plughw:cniotcore,1 path-to-speaker-sound.wav

	install -Dm644 "${SRC}/packages/bsp/cainiao-cniot-core/cniot-core-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/axg-sound-card/cniot-core-HiFi.conf"
	install -Dm644 "${SRC}/packages/bsp/cainiao-cniot-core/cniot-core.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/axg-sound-card/cniot-core.conf"

	if [ ! -d "${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card" ]; then
		mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card"
	fi
	ln -sfv /usr/share/alsa/ucm2/Amlogic/axg-sound-card/cniot-core.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card/cniot-core.conf"
}

function build_custom_uboot__cainiao-xiaoyi-pro() {
	display_alert "${BOARD}" "Use vendor U-Boot binary with Secure Boot enabled" "info"

	cp "${SRC}/cache/sources/amlogic-fip-blobs/cainiao-xiaoyi-pro/DDR_ENC.USB" .
	cp "${SRC}/cache/sources/amlogic-fip-blobs/cainiao-xiaoyi-pro/env-autobootcmd" .
	cp "${SRC}/cache/sources/amlogic-fip-blobs/cainiao-xiaoyi-pro/reserved-min-ept" .

	loop_over_uboot_targets_and_do deploy_built_uboot_bins_for_one_target_to_packaging_area
	declare -g EXTENSION_BUILT_UBOOT=yes
}
