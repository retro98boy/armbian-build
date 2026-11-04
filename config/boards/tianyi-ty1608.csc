# Amlogic S905L3-B 1GB RAM 8GB eMMC microSD FE USB2 MT7668RSN WiFi/BT
BOARD_NAME="TY1608"
BOARD_VENDOR="tianyi"
BOARDFAMILY="meson-gxl"
BOARD_MAINTAINER="retro98boy"
INTRODUCED="2025"
BOOTCONFIG="tianyi-ty1608_defconfig"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="yes"
SERIALCON="ttyAML0"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="amlogic/meson-gxlx2-s905l3-tianyi-ty1608.dtb"
PACKAGE_LIST_BOARD="alsa-ucm-conf"
BOOTBRANCH_BOARD="tag:v2026.10"
BOOTPATCHDIR="v2026.10"

# Use two safeguards against vendor Bluetooth driver conflicts: block btmtksdio module autoload and built-in initialization.
MODULES_BLACKLIST="btmtksdio"
function image_specific_armbian_env_ready__tianyi_ty1608_disable_btmtksdio() {
	# This need CONFIG_KALLSYMS=y
	run_host_command_logged echo "extraboardargs=initcall_blacklist=btmtksdio_driver_init" >>"${SDCARD}/boot/armbianEnv.txt"
}

enable_extension "gxlimg"
enable_extension "amlogic-fip-blobs"

function post_family_config__use_repacked_fip() {
	declare -g UBOOT_TARGET_MAP="u-boot.bin"
	unset write_uboot_platform

	function write_uboot_platform() {
		dd if="$1/u-boot.bin" of="$2" bs=512 seek=1 conv=fsync,notrunc 2>&1
	}
}

function post_uboot_custom_postprocess__repack_vendor_fip_with_mainline_uboot() {
	TMP_DIR=$(mktemp -d)
	trap 'rm -rf "$TMP_DIR"' EXIT
	run_host_command_logged dd \
		if="${SRC}/cache/sources/amlogic-fip-blobs/tianyi-ty1608/mmcblk0boot0" \
		of="${TMP_DIR}/fip" \
		bs=512 skip=1 conv=fsync,notrunc

	gxlimg_repack_fip_with_new_uboot "${TMP_DIR}/fip" gxlx2
}

function post_family_tweaks_bsp__tianyi-ty1608() {
	display_alert "${BOARD}" "Installing ALSA UCM configuration files" "info"

	# Use ALSA UCM via CLI:
	# alsactl init hw:S905XP212 && alsaucm -c hw:S905XP212 set _verb "HiFi" set _enadev "HDMI"
	# or
	# alsactl init hw:S905XP212 && alsaucm -c hw:S905XP212 set _verb "HiFi" set _enadev "Lineout"
	# playback: aplay -D plughw:S905XP212,0 /usr/share/sounds/alsa/Front_Center.wav

	install -Dm644 "${SRC}/packages/bsp/S905X-P212/S905X-P212-HiFi.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/gx-sound-card/S905X-P212-HiFi.conf"
	install -Dm644 "${SRC}/packages/bsp/S905X-P212/S905X-P212.conf" \
		"${destination}/usr/share/alsa/ucm2/Amlogic/gx-sound-card/S905X-P212.conf"

	mkdir -p "${destination}/usr/share/alsa/ucm2/conf.d/gx-sound-card"
	ln -sfv ../../Amlogic/gx-sound-card/S905X-P212.conf \
		"${destination}/usr/share/alsa/ucm2/conf.d/gx-sound-card/S905X-P212.conf"
}

function post_family_config__tianyi_ty1608_kernel_headers() {
	declare -g INSTALL_HEADERS="yes"
}

function post_install_kernel_debs__tianyi_ty1608_mt7668() {
	local version="2026.10.31.035716+gitcac075fc78c3"
	local package deb_file url
	declare -ag if_error_find_files_sdcard=("/var/lib/dkms/mt7668/*/build/make.log")

	for package in mt7668-firmware mt7668-dkms; do
		deb_file="${package}_${version}_all.deb"
		url="${GITHUB_SOURCE}/retro98boy/mt7668/releases/download/${version}/${deb_file}"

		run_host_command_logged curl --fail --location --retry 3 --connect-timeout 15 --max-time 300 \
			"${url@Q}" --output "${SDCARD@Q}/tmp/${deb_file}" || return 1
		use_clean_environment="yes" chroot_sdcard_apt_get_install "/tmp/${deb_file}" || return 1
		run_host_command_logged rm -- "${SDCARD@Q}/tmp/${deb_file}"
	done
}
