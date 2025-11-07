# Qualcomm QCS8250 LPDDR5 UFS USB3 Type-C DP Alt Mode WiFi6 BT5.1 1000BASE-T1 GMSL2
declare -g BOARD_NAME="DAMO Cockpit8250 ABL"
declare -g BOARD_MAINTAINER="retro98boy"
declare -g BOARDFAMILY="sm8250"
declare -g KERNEL_TARGET="current"
declare -g KERNEL_TEST_TARGET="current"
declare -g EXTRAWIFI="no"
declare -g PACKAGE_LIST_BOARD="alsa-ucm-conf" # Contain ALSA UCM top-level configuration file
declare -g BOOTCONFIG="none"
declare -g IMAGE_PARTITION_TABLE="gpt"
declare -g -a ABL_DTB_LIST=("sm8250-damo-cockpit8250")

# Use the full firmware, complete linux-firmware plus Armbian's (for qcom/a650_sqe.fw)
declare -g BOARD_FIRMWARE_INSTALL="-full"

function damo-cockpit8250_is_userspace_supported() {
	[[ "${RELEASE}" == "jammy" ]] && return 0
	[[ "${RELEASE}" == "trixie" ]] && return 0
	[[ "${RELEASE}" == "noble" ]] && return 0
	return 1
}

function post_family_tweaks_bsp__damo-cockpit8250_firmware() {
	display_alert "$BOARD" "Install firmwares for DAMO Cockpit8250" "info"

	# Bluetooth MAC addr setup service
	mkdir -p $destination/usr/local/bin/
	mkdir -p $destination/usr/lib/systemd/system/
	install -Dm655 $SRC/packages/bsp/generate-bt-mac-addr/bt-fixed-mac.sh $destination/usr/local/bin/
	install -Dm644 $SRC/packages/bsp/generate-bt-mac-addr/bt-fixed-mac.service $destination/usr/lib/systemd/system/

	# Kernel postinst script to update abl boot partition
	install -Dm655 $SRC/packages/bsp/damo-cockpit8250/zz-update-abl-kernel $destination/etc/kernel/postinst.d/

	# Add firmwares
	mkdir -p $destination/lib/firmware/qcom/sm8250/damo-cockpit8250
	install -Dm644 $SRC/packages/bsp/damo-cockpit8250/qupfw.mbn $destination/lib/firmware/qcom/sm8250/damo-cockpit8250/

	return 0
}

function post_family_tweaks__damo-cockpit8250_enable_services() {
	if ! damo-cockpit8250_is_userspace_supported; then
		if [[ "${RELEASE}" != "" ]]; then
			display_alert "Missing userspace for ${BOARD}" "${RELEASE} does not have the userspace necessary to support the ${BOARD}" "warn"
		fi
		return 0
	fi

	if [[ "${RELEASE}" == "jammy" ]] || [[ "${RELEASE}" == "noble" ]]; then
		display_alert "Adding qcom-mainline PPA" "${BOARD}" "info"
		do_with_retries 3 chroot_sdcard add-apt-repository ppa:liujianfeng1994/qcom-mainline --yes --no-update
	fi

	# we need unudhcpd from armbian repo, so enable it
	mv "${SDCARD}"/etc/apt/sources.list.d/armbian.sources.disabled "${SDCARD}"/etc/apt/sources.list.d/armbian.sources

	do_with_retries 3 chroot_sdcard_apt_get_update
	display_alert "$BOARD" "Installing board tweaks" "info"
	do_with_retries 3 chroot_sdcard_apt_get_install qbootctl qrtr-tools unudhcpd mkbootimg dropbear-bin

	# disable armbian repo back
	mv "${SDCARD}"/etc/apt/sources.list.d/armbian.sources "${SDCARD}"/etc/apt/sources.list.d/armbian.sources.disabled
	do_with_retries 3 chroot_sdcard_apt_get_update

	chroot_sdcard systemctl enable qbootctl.service
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
		"${destination}/usr/share/alsa/ucm2/conf.d/sm8250/damo-cockpit8250.conf"
}
