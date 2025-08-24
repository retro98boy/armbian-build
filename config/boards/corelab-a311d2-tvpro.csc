# Amlogic A311D2 8GB
BOARD_NAME="CoreLab A311D2-TVPro"
BOARDFAMILY="meson-s4t7"
KERNEL_TARGET="legacy"
MODULES_BLACKLIST="iv009_isp iv009_isp_sensor iv009_isp_lens iv009_isp_iq"
BOARD_MAINTAINER=""
SERIALCON="ttyS0" # for vendor kernel
# BOOT_FDT_FILE="amlogic/tvpro.dtb" # not set on purpose; u-boot auto-selects tvpro.dtb or tvpron.dtb

# build uboot from source
BOOTCONFIG="tvpro_defconfig"
KHADAS_BOARD_ID="tvpro" # used to compile the fip blobs

OVERLAY_PREFIX='t7-a311d2'

function post_family_config__corelab-a311d2-tvpro() {
	unset ASOUND_STATE
}

function tvpro_bsp_legacy_postinst_link_video_firmware() {
	ln -sf video_ucode.bin.t7 /lib/firmware/video/video_ucode.bin
}

function post_family_tweaks_bsp__tvpro_link_video_firmware_on_install() {
	postinst_functions+=(tvpro_bsp_legacy_postinst_link_video_firmware)
}
