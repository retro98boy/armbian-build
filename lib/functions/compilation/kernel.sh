#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2013-2023 Igor Pecovnik, igor@armbian.com
#
# This file is a part of the Armbian Build Framework
# https://github.com/armbian/build/

function compile_kernel() {
	declare kernel_work_dir="${SRC}/cache/sources/${LINUXSOURCEDIR}"
	display_alert "Kernel build starting" "${LINUXSOURCEDIR}" "info"

	# Prepare the git bare repo for the kernel; shared between all kernel builds
	declare kernel_git_bare_tree
	declare git_bundles_dir="${SRC}/cache/git-bundles/kernel"

	# @TODO: have a way to actually use this. It's inefficient, but might be the only way for people without ORAS/OCI for some reason.
	# Important: for the bundle version, gotta use "do_with_logging_unless_user_terminal" otherwise floods logs.
	# alternative # LOG_SECTION="kernel_prepare_bare_repo_from_bundle" do_with_logging_unless_user_terminal do_with_hooks \
	# alternative # 	kernel_prepare_bare_repo_from_bundle # this sets kernel_git_bare_tree

	# @TODO: Decide which kind of gitball to use: shallow or full.
	declare bare_tree_done_marker_file=".git/armbian-bare-tree-done"
	declare git_bundles_dir
	declare git_kernel_ball_fn
	declare git_kernel_oras_ref
	kernel_prepare_bare_repo_decide_shallow_or_full # sets kernel_git_bare_tree, git_bundles_dir, git_kernel_ball_fn, git_kernel_oras_ref

	LOG_SECTION="kernel_prepare_bare_repo_from_oras_gitball" do_with_logging do_with_hooks \
		kernel_prepare_bare_repo_from_oras_gitball # this sets kernel_git_bare_tree

	# prepare the working copy; this is the actual kernel source tree for this build
	declare checked_out_revision_ts="" checked_out_revision="undetermined" # set by fetch_from_repo
	LOG_SECTION="kernel_prepare_git" do_with_logging_unless_user_terminal do_with_hooks kernel_prepare_git

	# Capture date variables set by fetch_from_repo; it's the date of the last kernel revision
	declare kernel_git_revision="${checked_out_revision}"
	declare kernel_base_revision_ts="${checked_out_revision_ts}"
	declare kernel_base_revision_date # Used for KBUILD_BUILD_TIMESTAMP in make.
	kernel_base_revision_date="$(LC_ALL=C date -d "@${kernel_base_revision_ts}")"
	display_alert "Using Kernel git revision" "${kernel_git_revision} at '${kernel_base_revision_date}'"

	# Call extension method to prepare extra sources
	call_extension_method "kernel_copy_extra_sources" <<- 'ARMBIAN_KERNEL_SOURCES_EXTRA'
		*Hook to copy extra kernel sources to the kernel under compilation*
	ARMBIAN_KERNEL_SOURCES_EXTRA

	# Possibly 'make clean'.
	LOG_SECTION="kernel_maybe_clean" do_with_logging do_with_hooks kernel_maybe_clean

	# Patching.
	declare hash pre_patch_version
	kernel_main_patching # has it's own logging sections inside

	# Stop after patching.
	if [[ "${PATCH_ONLY}" == yes ]]; then
		display_alert "PATCH_ONLY is set, stopping." "PATCH_ONLY=yes and patching success" "cachehit"
		return 0
	fi

	# Stop after creating patches.
	if [[ "${CREATE_PATCHES}" == yes ]]; then
		display_alert "Stopping after creating kernel patch" "" "cachehit"
		return 0
	fi

	# patching worked, it's a good enough indication the git-bundle worked;
	# let's clean up the git-bundle cache, since the git-bare cache is proven working.
	LOG_SECTION="kernel_cleanup_bundle_artifacts" do_with_logging do_with_hooks kernel_cleanup_bundle_artifacts

	# re-read kernel version after patching
	declare version
	version=$(grab_version "$kernel_work_dir")

	# determine the toolchain
	declare toolchain
	LOG_SECTION="kernel_determine_toolchain" do_with_logging do_with_hooks kernel_determine_toolchain

	kernel_config # has it's own logging sections inside

	# Validate dts file if flag is set and stop after validation.
	# Has to happen after kernel .config file was created
	if [[ "${DTS_VALIDATE}" == yes ]]; then
		LOG_SECTION="validate_dts" do_with_logging validate_dts
		display_alert "DTS_VALIDATE is set, stopping." "DTS_VALIDATE=yes and dts sucessfully checked. See output above to fix your board's dts file." "cachehit"
		return 0
	fi

	# Stop after configuring kernel, but only if using a specific CLI command ("kernel-config").
	# Normal "KERNEL_CONFIGURE=yes" (during image build) is still allowed.
	if [[ "${KERNEL_CONFIGURE}" == yes && "${ARMBIAN_COMMAND}" == *kernel-config ]]; then
		display_alert "Stopping after configuring kernel" "" "cachehit"
		return 0
	fi

	display_alert "Compiling $BRANCH kernel" "$version" "info"

	# build via make and package .debs; they're separate sub-steps
	kernel_prepare_build_and_package # has it's own logging sections inside

	display_alert "Done with" "kernel compile" "debug"

	return 0
}

function kernel_maybe_clean() {
	if [[ $CLEAN_LEVEL == *make-kernel* ]]; then
		display_alert "Cleaning Kernel tree - CLEAN_LEVEL contains 'make-kernel'" "$LINUXSOURCEDIR" "info"
		(
			cd "${kernel_work_dir}" || exit_with_error "Can't cd to kernel_work_dir: ${kernel_work_dir}"
			run_host_command_logged git clean -xfdq # faster & more efficient than 'make clean'
		)
	else
		display_alert "Not cleaning Kernel tree; use CLEAN_LEVEL=make-kernel if needed" "CLEAN_LEVEL=${CLEAN_LEVEL}" "debug"
	fi
}

function kernel_prepare_build_and_package() {
	declare -a build_targets
	declare kernel_dest_install_dir
	declare -a install_make_params_quoted
	declare -A kernel_install_dirs

	build_targets=("all") # "All" builds the vmlinux/Image/Image.gz default for the ${ARCH}
	build_targets+=("${KERNEL_IMAGE_TYPE}")
	declare cleanup_id="" kernel_dest_install_dir=""
	prepare_temp_dir_in_workdir_and_schedule_cleanup "kernel_dest_install_dir" cleanup_id kernel_dest_install_dir # namerefs

	# define dict with vars passed and target directories
	declare -A kernel_install_dirs=(
		["INSTALL_PATH"]="${kernel_dest_install_dir}/image/boot"       # Used by `make install`
		["INSTALL_MOD_PATH"]="${kernel_dest_install_dir}/modules"      # Used by `make modules_install`
		["INSTALL_HDR_PATH"]="${kernel_dest_install_dir}/libc_headers" # Used by `make headers_install` for libc headers
	)

	[ -z "${SRC_LOADADDR}" ] || install_make_params_quoted+=("${SRC_LOADADDR}") # For uImage

	# @TODO: Only combining `install` and `modules_install` enable mixed-build and __build_one_by_one
	# We should spilt the `build` and `install` into two make steps as the kernel required
	build_targets+=("install" "${KERNEL_INSTALL_TYPE:-install}")

	install_make_params_quoted+=("INSTALL_MOD_STRIP=1") # strip modules during install

	build_targets+=("modules_install")
	build_targets+=("headers_install") # headers_install for libc headers
	if [[ "${KERNEL_BUILD_DTBS:-yes}" == "yes" ]]; then
		display_alert "Kernel build will produce DTBs!" "DTBs YES" "debug"
		build_targets+=("dtbs_install")
		kernel_install_dirs+=(["INSTALL_DTBS_PATH"]="${kernel_dest_install_dir}/dtbs") # Used by `make dtbs_install`
	fi

	# loop over the keys above, get the value, create param value in array; also mkdir the dir
	local dir_key
	for dir_key in "${!kernel_install_dirs[@]}"; do
		local dir="${kernel_install_dirs["${dir_key}"]}"
		local value="${dir_key}=${dir}"
		mkdir -p "${dir}"
		install_make_params_quoted+=("${value}")
	done

	if [[ "${KERNEL_DTB_ONLY}" == "yes" ]]; then
		# Helper for local development of device tree
		kernel_dtb_only_build
	else
		# Normal build, which includes "all" target etc
		LOG_SECTION="kernel_build" do_with_logging do_with_hooks kernel_build
	fi

	# Package what has been built
	LOG_SECTION="kernel_package" do_with_logging do_with_hooks kernel_package

	done_with_temp_dir "${cleanup_id}" # changes cwd to "${SRC}" and fires the cleanup function early
}

function kernel_dtb_only_build() {
	display_alert "Kernel DTB-only for development" "KERNEL_DTB_ONLY: ${KERNEL_DTB_ONLY}" "info"
	# Do it in two separate steps, first build the dtbs then install them.
	build_targets=("dtbs")
	LOG_SECTION="kernel_build" do_with_logging do_with_hooks kernel_build

	display_alert "Kernel DTB-only for development" "Installing DTBs" "info"
	build_targets=("dtbs_install")
	LOG_SECTION="kernel_build" do_with_logging do_with_hooks kernel_build

	display_alert "Kernel DTB-only .deb, for development/convenience" "kernel dtb build done" "info"

	display_alert "Considering further .dts convenience processing" "for board '${BOARD}' branch '${BRANCH}'" "info"

	# If BOOT_FDT_FILE is not set, bail.
	if [[ -z "${BOOT_FDT_FILE}" ]]; then
		display_alert "Board '${BOARD}' branch '${BRANCH}'" "No BOOT_FDT_FILE set for board, skipping further processing" "warn"
		return 0
	fi

	display_alert "Kernel DTB-only for development" "Copying preprocessed versions of ${BOOT_FDT_FILE}" "info"

	declare fdt_dir fdt_file                 # we need to parse these out of BOOT_FDT_FILE
	if [[ "${BOOT_FDT_FILE}" == */* ]]; then # If BOOT_FDT_FILE contains a slash (/), means it's using vendor/board.dtb scheme;  we can parse that.
		[[ "${BOOT_FDT_FILE}" =~ ^(.*)/(.*)$ ]] && fdt_dir="${BASH_REMATCH[1]}" && fdt_file="${BASH_REMATCH[2]}"
	else
		display_alert "Kernel DTB-only for development" "BOOT_FDT_FILE does not contain a slash, skipping further processing" "warn"
		return 0
	fi

	if [[ -z "${fdt_dir}" || -z "${fdt_file}" ]]; then # Check it worked, or bail
		display_alert "Failed to parse BOOT_FDT_FILE" "BOOT_FDT_FILE: '${BOOT_FDT_FILE}'" "err"
		return 0
	fi

	# Copy the bin dtb for convenience
	display_alert "Kernel DTB-only for development" "Copying binary ${BOOT_FDT_FILE}" "info"
	declare binary_dtb="${kernel_work_dir}/arch/${KERNEL_SRC_ARCH}/boot/dts/${fdt_dir}/${fdt_file}"
	declare binary_dtb_dest="${SRC}/output/${fdt_dir}-${fdt_file}--${KERNEL_MAJOR_MINOR}-${BRANCH}.dtb"
	run_host_command_logged cp -v "${binary_dtb}" "${binary_dtb_dest}"

	# Kernel build should produce a preprocessed version of all DTS files built into DTBs at arch/arm64/boot/dts/${fdt_dir}/.${fdt_file}.dts.tmp
	declare preprocessed_fdt_source="${kernel_work_dir}/arch/${KERNEL_SRC_ARCH}/boot/dts/${fdt_dir}/.${fdt_file}.dts.tmp"

	# Check it exists, or bail
	if [[ ! -f "${preprocessed_fdt_source}" ]]; then
		exit_with_error "Preprocessed FDT source not found: ${preprocessed_fdt_source}"
	fi

	declare preprocessed_fdt_dest="${SRC}/output/${fdt_dir}-${fdt_file}--${KERNEL_MAJOR_MINOR}-${BRANCH}.preprocessed.dts"
	run_host_command_logged cp -v "${preprocessed_fdt_source}" "${preprocessed_fdt_dest}"

	# Include a normalization pass through the dtc tool, with DTS as both input and output formats; this introduces phandles, unfortunately
	display_alert "Kernel DTB-only for development" "Normalizing (dtc dts-to-dts) preprocessed FDT" "info"
	declare preprocessed_fdt_normalized="${SRC}/output/${fdt_dir}-${fdt_file}--${KERNEL_MAJOR_MINOR}-${BRANCH}.preprocessed.normalized.dts"
	run_host_command_logged dtc -I dts -O dts -o "${preprocessed_fdt_normalized}" "${preprocessed_fdt_dest}"

	# Remove phandles and hex references, probably the worst way possible (grep) -- somehow the diff is reasonable then, but also phandle references are gone. Less useful.
	declare preprocessed_fdt_normalized_nophandles="${SRC}/output/${fdt_dir}-${fdt_file}--${KERNEL_MAJOR_MINOR}-${BRANCH}.preprocessed.normalized.nophandles.dts"
	grep -v -e "phandle =" -e "connect =" -e '= <0x' "${preprocessed_fdt_normalized}" > "${preprocessed_fdt_normalized_nophandles}"

	display_alert "Kernel DTB-only for development" "Preprocessed FDT dest: ${preprocessed_fdt_dest}" "info"
	display_alert "Kernel DTB-only for development" "Preprocessed FDT normalized: ${preprocessed_fdt_normalized}" "info"
	display_alert "Kernel DTB-only for development" "Preprocessed FDT normalized, no phandles: ${preprocessed_fdt_normalized_nophandles}" "info"
}

function kernel_build() {
	local ts=${SECONDS}
	cd "${kernel_work_dir}" || exit_with_error "Can't cd to kernel_work_dir: ${kernel_work_dir}"

	display_alert "Building kernel" "${LINUXFAMILY} ${LINUXCONFIG} ${build_targets[*]}" "info"
	# make_filter="| grep --line-buffered -v -e 'LD' -e 'AR' -e 'INSTALL' -e 'SIGN' -e 'XZ' " \ # @TODO this will be summarised in the log file eventually, but shown in realtime in screen
	do_with_ccache_statistics \
		run_kernel_make_long_running "${install_make_params_quoted[@]@Q}" "${build_targets[@]}" # "V=1" # "-s" silent mode, "V=1" verbose mode

	display_alert "Kernel built in" "$((SECONDS - ts)) seconds - ${version}-${LINUXFAMILY}" "info"
}

function kernel_package() {
	local ts=${SECONDS}
	cd "${kernel_work_dir}" || exit_with_error "Can't cd to kernel_work_dir: ${kernel_work_dir}"
	display_alert "Packaging kernel" "${LINUXFAMILY} ${LINUXCONFIG}" "info"
	prepare_kernel_packaging_debs "${kernel_work_dir}" "${kernel_dest_install_dir}" "${version}" kernel_install_dirs
	display_alert "Kernel packaged in" "$((SECONDS - ts)) seconds - ${version}-${LINUXFAMILY}" "info"
}
