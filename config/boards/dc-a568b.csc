# Rockchip RK3568, RK809, eMMC, HDMI, RMII Ethernet, AIC8800DC SDIO Wi-Fi and UART Bluetooth.
BOARD_NAME="DC-A568B"
BOARD_MAINTAINER=""
BOARDFAMILY="rk35xx"
INTRODUCED="2026"
BOOT_SOC="rk3568"
KERNEL_TARGET="current,edge,vendor"
KERNEL_TEST_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3568-dc-a568b-p1.dtb"
BOOT_SCENARIO="binman"
IMAGE_PARTITION_TABLE="gpt"
MODULES_VENDOR="panel-simple pwm_bl"
MODULES_CURRENT="panel-rocknix-generic-dsi pwm_bl"
MODULES_EDGE="panel-rocknix-generic-dsi pwm_bl"
PACKAGE_LIST_BOARD="bluez rfkill"

# The stock AIC8800DC user configuration matches this Radxa release.
# Several firmware binaries differ. Use Radxa's paired driver and firmware; board testing remains required.
enable_extension "radxa-aic8800"
AIC8800_TYPE="sdio"

function post_family_config__dc_a568b() {
	declare -g BOOTCONFIG="dc-a568b-rk3568_defconfig"
	declare -g BOOTSOURCE="https://github.com/u-boot/u-boot.git"
	declare -g BOOTBRANCH="tag:v2026.07"
	declare -g BOOTPATCHDIR="v2026.07"
	declare -g BOOTDIR="u-boot-${BOARD}"
}
