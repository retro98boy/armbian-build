# Amlogic A311D2, 4GB/8GB LPDDR4, eMMC, GbE, SDIO Wi-Fi/BT, HDMI
BOARD_NAME="CoreLab TVPro"
BOARD_VENDOR="corelab"
BOARDFAMILY="meson-s4t7"
KERNEL_TARGET="edge"
INTRODUCED="2026"
SERIALCON="ttyS0"
BOOTCONFIG="tvpro_defconfig"
KHADAS_BOARD_ID="tvpro"
OVERLAY_PREFIX="t7-a311d2"
# U-Boot selects the DTB from the detected 4GB/8GB memory size.
PACKAGE_LIST_BOARD="alsa-ucm-conf"

function post_family_tweaks_bsp__corelab_tvpro_ucm() {
	install -Dm644 "${SRC}/packages/bsp/corelab-tvpro/CORELAB-TVPRO.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/axg-sound-card/CORELAB-TVPRO.conf"
	install -Dm644 "${SRC}/packages/bsp/corelab-tvpro/HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/axg-sound-card/CORELAB-TVPRO-HiFi.conf"
	mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card"
	ln -sf ../../Amlogic/axg-sound-card/CORELAB-TVPRO.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card/CORELAB-TVPRO.conf"
}

function custom_kernel_config__corelab_tvpro_fan() {
	opts_y+=("PWM_GPIO" "SENSORS_PWM_FAN")
}

function pre_install_kernel_debs__corelab_tvpro_boot_args() {
	run_host_command_logged echo "extraargs=net.ifnames=0 no_console_suspend mem_sleep_default=s2idle" >> "${SDCARD}"/boot/armbianEnv.txt
}
