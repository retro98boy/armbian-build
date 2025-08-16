# Amlogic A311D 4GB RAM 8GB eMMC GBE USB 2.0 PCIe ASM1064
BOARD_NAME="OneThing Cloud OES"
BOARDFAMILY="meson-g12b"
BOARD_MAINTAINER=""
OFFSET="100" # Reserved for the EPT and vendor U-Boot env
BOOTSIZE="256"
BOOTFS_TYPE="fat"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="no"
SERIALCON="ttyAML0"
BOOT_FDT_FILE="amlogic/meson-g12b-a311d-oes.dtb"
PACKAGE_LIST_BOARD="libubootenv-tool ttyd"

function post_family_config__onethingcloud-oes() {
	display_alert "$BOARD" "Use vendor U-Boot to boot the kernel" "info"

	unset BOOTSOURCE
	declare -g BOOTCONFIG="none"
	declare -g BOOTSCRIPT="boot-onethingcloud-oes.cmd:boot.cmd"

	unset post_build_image_modify
	post_build_image_modify() {
		local IMAGE=${1}
		BLOBS_DIR="${SRC}/cache/sources/onethingcloud-oes"

		display_alert "${BOARD}" "Installing the vendor FIP with secure boot enabled to sdcard.img" "info"

		dd if="${BLOBS_DIR}/DDR_ENC.USB" of="$IMAGE" bs=512 seek=1 conv=fsync,notrunc 2>&1
		dd if="${BLOBS_DIR}/env-main" of="$IMAGE" bs=1MiB seek=4 conv=fsync,notrunc 2>&1 # Vendor U-Boot env with autoboot cmd
		dd if="${BLOBS_DIR}/reserved" of="$IMAGE" bs=1MiB seek=36 conv=fsync,notrunc 2>&1 # Contain EPT
	}

	unset ASOUND_STATE
}

function post_family_tweaks__onethingcloud-oes() {
	fetch_from_repo "https://github.com/retro98boy/onethingcloud-oes-linux.git" "onethingcloud-oes" "commit:0f5277b9a59101f4baa3fa5f30376dc091764ce4"
	BLOBS_DIR="${SRC}/cache/sources/onethingcloud-oes"

	display_alert "${BOARD}" "Installing the aml_autoscript to set U-Boot autoboot cmd on first startup" "info"

	install -Dm755 "${BLOBS_DIR}/aml_autoscript.cmd" "${SDCARD}/boot/aml_autoscript.cmd"
	install -Dm755 "${BLOBS_DIR}/aml_autoscript" "${SDCARD}/boot/aml_autoscript" # Vendor U-Boot will try to load it

	display_alert "${BOARD}" "Installing U-Boot env setting" "info"

	cat <<- EOF > "${SDCARD}/etc/fw_env.config"
		# stock EPT
		# /dev/mmcblk1 0x27400000 0x10000 0x27410000 0x10000
		/dev/mmcblk1 0x400000 0x10000 0x410000 0x10000
	EOF

	display_alert "${BOARD}" "Setting TTYD" "info"

	cat <<- EOF > "${SDCARD}/etc/default/ttyd"
		TTYD_OPTIONS="-W -p 7681 -O login"
	EOF
}
