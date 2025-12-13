# Amlogic A311D2 LPDDR4X eMMC GBE USB3 HDMI TX/RX LINE OUT/IN AP6256 WiFi/BT
BOARD_NAME="CoreLab TVPro"
BOARDFAMILY="meson-s4t7"
KERNEL_TARGET="legacy"
MODULES_BLACKLIST="iv009_isp iv009_isp_sensor iv009_isp_lens iv009_isp_iq"
BOARD_MAINTAINER="retro98boy"
SERIALCON="ttyS0" # for vendor kernel
# BOOT_FDT_FILE="amlogic/t7-a311d2-tvpro-8g.dtb" # not set on purpose; u-boot auto-selects fdt file

# build uboot from source
BOOTCONFIG="tvpro_defconfig"
KHADAS_BOARD_ID="tvpro" # used to compile the fip blobs

OVERLAY_PREFIX='t7-a311d2'

function post_family_config__tvpro() {
	unset ASOUND_STATE
}

function tvpro_bsp_legacy_postinst_link_video_firmware() {
	ln -sf video_ucode.bin.t7 /lib/firmware/video/video_ucode.bin
}

function post_family_tweaks_bsp__tvpro() {
	postinst_functions+=(tvpro_bsp_legacy_postinst_link_video_firmware)

	display_alert "${BOARD}" "Installing ALSA UCM configuration files" "info"

	install -Dm644 "${SRC}/packages/bsp/corelab-tvpro/corelab-tvpro-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/corelab-tvpro/corelab-tvpro-HiFi.conf"
	install -Dm644 "${SRC}/packages/bsp/corelab-tvpro/corelab-tvpro.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/corelab-tvpro/corelab-tvpro.conf"

	if [ ! -d "${destination}/usr/share/alsa/ucm2/conf.d/corelab-tvpro" ]; then
		mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/corelab-tvpro"
	fi
	ln -sfv /usr/share/alsa/ucm2/Amlogic/corelab-tvpro/corelab-tvpro.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/corelab-tvpro/corelab-tvpro.conf"
}

function pre_install_kernel_debs__extra_boot_args() {
	display_alert "$BOARD" "Add extra boot arguments" "info"
	run_host_command_logged echo "extraargs=net.ifnames=0 no_console_suspend" >> "${SDCARD}"/boot/armbianEnv.txt

	return 0
}
