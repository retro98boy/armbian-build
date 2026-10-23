# Amlogic A311D2, 4GB LPDDR4, eMMC, GbE, USB hubs, HDMI
BOARD_NAME="AOC 65T33Z"
BOARD_VENDOR="aoc"
BOARDFAMILY="meson-s4t7"
KERNEL_TARGET="edge"
INTRODUCED="2026"
SERIALCON="ttyS0"
BOOTCONFIG="65t33z_defconfig"
KHADAS_BOARD_ID="65t33z"
OVERLAY_PREFIX="t7-a311d2"
PACKAGE_LIST_BOARD="alsa-ucm-conf"

function post_family_tweaks_bsp__aoc_65t33z_ucm() {
	install -Dm644 "${SRC}/packages/bsp/aoc-65t33z/AOC-65T33Z.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/axg-sound-card/AOC-65T33Z.conf"
	install -Dm644 "${SRC}/packages/bsp/aoc-65t33z/HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/axg-sound-card/AOC-65T33Z-HiFi.conf"
	mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card"
	ln -sf ../../Amlogic/axg-sound-card/AOC-65T33Z.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/axg-sound-card/AOC-65T33Z.conf"
}

function custom_kernel_config__aoc_65t33z_ethernet() {
	opts_y+=("MOTORCOMM_PHY")
}

function pre_install_kernel_debs__aoc_65t33z_boot_args() {
	run_host_command_logged echo "extraargs=net.ifnames=0 no_console_suspend mem_sleep_default=s2idle" >> "${SDCARD}"/boot/armbianEnv.txt
}
