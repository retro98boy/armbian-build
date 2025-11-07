# Qualcomm QCS8250 LPDDR5 UFS USB3 Type-C DP Alt Mode WiFi6 BT5.1 1000BASE-T1 GMSL2
declare -g BOARD_NAME="DAMO Cockpit8250"
declare -g BOARD_MAINTAINER="retro98boy"
declare -g BOARDFAMILY="sm8250"
declare -g KERNEL_TARGET="current"
declare -g KERNEL_TEST_TARGET="current"
declare -g EXTRAWIFI="no"
declare -g PACKAGE_LIST_BOARD="alsa-ucm-conf" # Contain ALSA UCM top-level configuration file
declare -g BOOTCONFIG="none"
declare -g BOOT_FDT_FILE="qcom/sm8250-damo-cockpit8250.dtb"
declare -g GRUB_CMDLINE_LINUX_DEFAULT="efi=noruntime console=ttyMSM0,115200n8"
enable_extension "grub-with-dtb"

# Use the full firmware, complete linux-firmware plus Armbian's (for qcom/a650_sqe.fw)
declare -g BOARD_FIRMWARE_INSTALL="-full"

function post_family_tweaks_bsp__damo-cockpit8250_firmware() {
	display_alert "$BOARD" "Install firmwares for DAMO Cockpit8250" "info"

	# Bluetooth MAC addr setup service
	mkdir -p $destination/usr/local/bin/
	mkdir -p $destination/usr/lib/systemd/system/
	install -Dm655 $SRC/packages/bsp/generate-bt-mac-addr/bt-fixed-mac.sh $destination/usr/local/bin/
	install -Dm644 $SRC/packages/bsp/generate-bt-mac-addr/bt-fixed-mac.service $destination/usr/lib/systemd/system/

	# Add firmwares
	mkdir -p $destination/lib/firmware/qcom/sm8250/damo-cockpit8250
	install -Dm644 $SRC/packages/bsp/damo-cockpit8250/qupfw.mbn $destination/lib/firmware/qcom/sm8250/damo-cockpit8250/

	return 0
}

function post_family_tweaks__damo-cockpit8250_enable_services() {
	chroot_sdcard systemctl enable bt-fixed-mac.service

	return 0
}

function post_family_tweaks_bsp__damo-cockpit8250_bsp_firmware_in_initrd() {
	display_alert "Adding to bsp-cli" "${BOARD}: firmware in initrd" "info"
	declare file_added_to_bsp_destination # will be filled in by add_file_from_stdin_to_bsp_destination
	add_file_from_stdin_to_bsp_destination "/etc/initramfs-tools/hooks/damo-cockpit8250-firmware" <<- 'FIRMWARE_HOOK'
		#!/bin/bash
		[[ "$1" == "prereqs" ]] && exit 0
		. /usr/share/initramfs-tools/hook-functions
		for f in /lib/firmware/qcom/sm8250/damo-cockpit8250/* ; do
			add_firmware "${f#/lib/firmware/}"
		done
		add_firmware "qcom/a650_sqe.fw" # extra one for dpu
		add_firmware "qcom/a650_gmu.bin" # extra one for gpu
	FIRMWARE_HOOK
	run_host_command_logged chmod -v +x "${file_added_to_bsp_destination}"
}

function post_family_tweaks_bsp__damo-cockpit8250_alsa-ucm() {
	display_alert "${BOARD}" "Installing ALSA UCM configuration files" "info"

	install -Dm644 "${SRC}/packages/bsp/damo-cockpit8250/damo-cockpit8250-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Qualcomm/sm8250/damo-cockpit8250-HiFi.conf"
	install -Dm644 "${SRC}/packages/bsp/damo-cockpit8250/damo-cockpit8250.conf" \
		"${destination}/usr/share/alsa/ucm2/Qualcomm/sm8250/damo-cockpit8250.conf"

	if [ ! -d "${destination}/usr/share/alsa/ucm2/conf.d/sm8250" ]; then
		mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/sm8250"
	fi
	ln -sfv /usr/share/alsa/ucm2/Qualcomm/sm8250/damo-cockpit8250.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/sm8250/damo-DAMOCockpit8250-.conf"
}
