# Amlogic A311D 4GB RAM 8GB eMMC GBE USB 2.0 PCIe ASM1064
BOARD_NAME="OneThing Cloud OES"
BOARDFAMILY="meson-g12b"
BOARD_MAINTAINER=""
OFFSET="636" # Reserved for the EPT partition table and vendor U-Boot env
BOOTSIZE="512"
BOOTFS_TYPE="fat"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
FULL_DESKTOP="no"
SERIALCON="ttyAML0"
BOOT_FDT_FILE="amlogic/meson-g12b-a311d-onethingcloud-oes.dtb"

function post_family_config__onethingcloud-oes() {
	display_alert "$BOARD" "Use vendor U-Boot to boot the kernel" "info"

	unset BOOTSOURCE
	declare -g BOOTCONFIG="none"
	declare -g BOOTSCRIPT="boot-onethingcloud-oes.cmd:boot.cmd"

	unset post_build_image_modify
	post_build_image_modify() {
		local IMAGE=${1}
		BLOBS_DIR="${SRC}/cache/sources/onethingcloud-oes-linux"

		display_alert "${BOARD}" "Installing the vendor FIP with secure boot enabled to sdcard.img" "info"

		dd if="${BLOBS_DIR}/DDR_ENC.USB" of="$IMAGE" bs=512 seek=1 conv=fsync,notrunc 2>&1
		dd if="${BLOBS_DIR}/env-main" of="$IMAGE" bs=1MiB seek=628 conv=fsync,notrunc 2>&1 # Vendor U-Boot env with autoboot cmd
		dd if="${BLOBS_DIR}/reserved" of="$IMAGE" bs=1MiB seek=36 conv=fsync,notrunc 2>&1 # EPT partition table
	}

	unset ASOUND_STATE

	case "${BRANCH}" in
		current)
			display_alert "$BOARD" "Use chewitt linux 5.19.y as the current kernel" "info"

			declare -g KERNELSOURCE="https://github.com/chewitt/linux"
			declare -g KERNEL_MAJOR_MINOR="5.19"
			declare -g KERNELBRANCH="branch:amlogic-5.19.y"
			declare -g LINUXFAMILY="oes-chewitt" # Separate kernel package from the regular `meson64` family
			declare -g LINUXCONFIG="linux-oes-chewitt"
			;;

		edge)
			# As is
	esac
}

function post_family_tweaks__onethingcloud-oes() {
	fetch_from_repo "https://github.com/retro98boy/onethingcloud-oes-linux.git" "onethingcloud-oes-linux" "commit:627336376d2b6c179cb2b759d16fe60e054758b9"
	BLOBS_DIR="${SRC}/cache/sources/onethingcloud-oes-linux"

	display_alert "${BOARD}" "Installing the aml_autoscript to set U-Boot autoboot cmd on first startup" "info"

	install -Dm755 "${BLOBS_DIR}/aml_autoscript.cmd" "${SDCARD}/boot/aml_autoscript.cmd"
	install -Dm755 "${BLOBS_DIR}/aml_autoscript" "${SDCARD}/boot/aml_autoscript" # Vendor U-Boot will try to load it

	display_alert "${BOARD}" "Installing fw_printenv and fw_setenv" "info"

	if [ ! -d "${SDCARD}/usr/local/bin" ]; then
		mkdir -p "${SDCARD}/usr/local/bin"
	fi
	install -Dm755 "${BLOBS_DIR}/fw_printenv" "${SDCARD}/usr/local/bin/fw_printenv"
	install -Dm755 "${BLOBS_DIR}/fw_printenv" "${SDCARD}/usr/local/bin/fw_setenv"

	case "${BRANCH}" in
		current)

			cat <<- EOF > "${SDCARD}/etc/fw_env.config"
				# main
				/dev/mmcblk1 0x27400000 0x10000
				# redundance
				# /dev/mmcblk1 0x27410000 0x10000
			EOF

			;;
		edge)

			cat <<- EOF > "${SDCARD}/etc/fw_env.config"
				# main
				/dev/mmcblk1 0x27400000 0x10000
				# redundance
				/dev/mmcblk1 0x27410000 0x10000
			EOF

	esac
}
