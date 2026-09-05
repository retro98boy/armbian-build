#!/usr/bin/env bash
# @description Fetches the Amlogic FIP (Firmware Image Package) blobs required for bootloader assembly on Amlogic SoCs. Clones `retro98boy/amlogic-fip-blobs` at a pinned commit into the sources tools cache via `fetch_from_repo`. Enabled for Amlogic boards whose u-boot build needs these proprietary firmware blobs to produce a bootable image.

function fetch_sources_tools__amlogic-fip-blobs() {
	fetch_from_repo "https://github.com/retro98boy/amlogic-fip-blobs" "amlogic-fip-blobs" "commit:44326a3748cc4d45b7cd0546063b7d3a2e6b3eb1"
}
