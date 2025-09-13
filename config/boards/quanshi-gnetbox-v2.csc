# Rockchip RK3399 hexa core 4GB LPDDR4 16GB eMMC GBE USB3 WiFi/BT
BOARD_NAME="GNETBox V2"
BOARD_VENDOR="quanshi"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="retro98boy"
INTRODUCED="2025"
BOOTCONFIG="gnetbox-v2-rk3399_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3399-gnetbox-v2.dtb"
BOOTBRANCH_BOARD="tag:v2026.10"
BOOTPATCHDIR="v2026.10"
SRC_EXTLINUX="yes"
SRC_CMDLINE="console=ttyS2,1500000 console=tty0"

function post_family_config__quanshi-gnetbox-v2() {
	declare -g BOOT_SCENARIO="spl-blobs"
	declare -g DDR_BLOB="rk33/rk3399_ddr_800MHz_v1.19.bin"
	declare -g BL31_BLOB="rk33/rk3399_bl31_v1.36.elf"
	declare -g UBOOT_TARGET_MAP="BL31=${RKBIN_DIR}/${BL31_BLOB} ROCKCHIP_TPL=${RKBIN_DIR}/${DDR_BLOB};;u-boot-rockchip.bin"
}

function pre_customize_image__quanshi-gnetbox-v2() {
	display_alert "${BOARD}" "Setting up AP6255 firmware symlinks" "info"

	if [ -f "${SDCARD}/lib/firmware/brcm/BCM4345C0_003.001.025.0162.0000_Generic_UART_37_4MHz_wlbga_ref_iLNA_iTR_eLG.hcd" ]; then
		ln -sfv BCM4345C0_003.001.025.0162.0000_Generic_UART_37_4MHz_wlbga_ref_iLNA_iTR_eLG.hcd \
			"${SDCARD}/lib/firmware/brcm/BCM4345C0.quanshi,gnetbox-v2.hcd"
	fi
	if [ -f "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.bin" ]; then
		ln -sfv brcmfmac43455-sdio.bin "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.quanshi,gnetbox-v2.bin"
	fi
	if [ -f "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.txt" ]; then
		ln -sfv brcmfmac43455-sdio.txt "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.quanshi,gnetbox-v2.txt"
	fi
	if [ -f "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.clm_blob" ]; then
		ln -sfv brcmfmac43455-sdio.clm_blob "${SDCARD}/lib/firmware/brcm/brcmfmac43455-sdio.quanshi,gnetbox-v2.clm_blob"
	fi
}
