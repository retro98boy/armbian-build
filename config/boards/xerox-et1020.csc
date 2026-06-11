# Rockchip RK3399 2GB DDR3 16GB eMMC tablet
BOARD_NAME="Xerox ET1020"
BOARD_VENDOR="xerox"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="retro98boy"
INTRODUCED="2024"
BOOTCONFIG="et1020-rk3399_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
MODULES_CURRENT="panel-simple-dsi"
MODULES_EDGE="panel-simple-dsi"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3399-et1020.dtb"
BOOTBRANCH_BOARD="tag:v2026.01"
BOOTPATCHDIR="v2026.01"
BOOT_SCENARIO="binman"
SRC_EXTLINUX="yes"
SRC_CMDLINE="console=ttyS2,1500000 console=tty0"

PACKAGE_LIST_BOARD="alsa-ucm-conf" # Contain ALSA UCM top-level configuration file

function post_family_tweaks_bsp__xerox-et1020() {
	display_alert "${BOARD}" "Installing ALSA UCM configuration files" "info"

	# Use ALSA UCM via CLI:
	# alsactl init hw:xeroxet1020 && alsaucm -c hw:xeroxet1020 set _verb "HiFi" set _enadev "Headphones" set _enadev "Speakers"
	# aplay -D plughw:xeroxet1020,0 /usr/share/sounds/alsa/Front_Center.wav

	install -Dm644 "${SRC}/packages/bsp/xerox-et1020/xerox-et1020-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/xerox-et1020/xerox-et1020-HiFi.conf"
	install -Dm644 "${SRC}/packages/bsp/xerox-et1020/xerox-et1020.conf" \
		"${destination}/usr/share/alsa/ucm2/Rockchip/xerox-et1020/xerox-et1020.conf"

	if [ ! -d "${destination}/usr/share/alsa/ucm2/conf.d/simple-card" ]; then
		mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/simple-card"
	fi
	ln -sfv /usr/share/alsa/ucm2/Rockchip/xerox-et1020/xerox-et1020.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/simple-card/xerox-et1020.conf"
}

function pre_customize_image__xerox-et1020() {
	display_alert "${BOARD}" "Setting up AP6255 firmware symlinks" "info"

	if [ -f "${SDCARD}/lib/firmware/brcm/BCM4345C0_003.001.025.0162.0000_Generic_UART_37_4MHz_wlbga_ref_iLNA_iTR_eLG.hcd" ]; then
		ln -sfv BCM4345C0_003.001.025.0162.0000_Generic_UART_37_4MHz_wlbga_ref_iLNA_iTR_eLG.hcd \
			"${SDCARD}/lib/firmware/brcm/BCM4345C0.xerox,et1020.hcd"
	fi
	if [ -f "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.bin" ]; then
		ln -sfv brcmfmac43455-sdio.bin "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.xerox,et1020.bin"
	fi
	if [ -f "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.txt" ]; then
		ln -sfv brcmfmac43455-sdio.txt "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.xerox,et1020.txt"
	fi
	if [ -f "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.clm_blob" ]; then
		ln -sfv brcmfmac43455-sdio.clm_blob "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.xerox,et1020.clm_blob"
	fi
}
