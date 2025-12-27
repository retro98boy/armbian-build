# Amlogic A311D2 LPDDR4X eMMC GBE USB3 HDMI TX/RX LINE OUT
BOARD_NAME="AOC 65T33Z"
BOARDFAMILY="meson-s4t7"
KERNEL_TARGET="legacy"
MODULES_BLACKLIST="iv009_isp iv009_isp_sensor iv009_isp_lens iv009_isp_iq"
PACKAGE_LIST_BOARD="alsa-ucm-conf" # Contain ALSA UCM top-level configuration file
BOARD_MAINTAINER="retro98boy"
SERIALCON="ttyS0" # for vendor kernel
# BOOT_FDT_FILE="amlogic/t7-a311d2-65t33z-4g.dtb" # not set on purpose; u-boot auto-selects fdt file

# build uboot from source
BOOTCONFIG="65t33z_defconfig"
KHADAS_BOARD_ID="65t33z" # used to compile the fip blobs

OVERLAY_PREFIX='t7-a311d2'

function post_family_config__65t33z() {
	unset ASOUND_STATE
}

function 65t33z_bsp_legacy_postinst_link_video_firmware() {
	ln -sf video_ucode.bin.t7 /lib/firmware/video/video_ucode.bin
}

function post_family_tweaks_bsp__65t33z() {
	postinst_functions+=(65t33z_bsp_legacy_postinst_link_video_firmware)

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
