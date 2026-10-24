CLINK-T68 uses the Rockchip 6.1 vendor kernel and mainline U-Boot v2026.07.
The default kernel DTB is `rockchip/rk3568-clink-t68-p1.dtb`.
Use `rockchip/rk3568-clink-t68.dtb` for HDMI without the internal display assembly.

Hardware follows the stock Android live DTS and driver bindings collected on 2026-11-03.
DC-A568B supplies the build configuration template.
U-Boot disables ADC download-key detection until the board's download-key channel is verified.

- RK817 supplies the board rails. DCDC4 supplies 3.3 V, rather than a separate NPU rail.
- GPU and NPU share DCDC2. The NPU bus uses DCDC1.
- GMAC1 uses RGMII M1, PHY address 0, and GPIO3_B0 reset.
- SDMMC1 connects AIC8801. UART1 M0 connects Bluetooth.
- UART3 M1, UART5 M1, UART7 M1, and UART8 M1 follow the stock configuration.
- I2C1 connects HYM8563 at 0x51 and MC3230 at 0x4c.
- RK817 audio uses I2S1, GPIO3_A1 amplifier control, and GPIO0_C3 headphone detection.
- USB retains the stock OTG port and separate host and hub power controls.
- GPIO1_B1 and GPIO1_B2 drive the blue and red LEDs.
- SARADC0 supplies four keys. PWM3 supplies the stock infrared key maps.
- GPIO4_D2 controls the fan. One GPIO supports two states; stock RPM values are nominal.
- GPIO0_A6 connects the PIR input. Its private driver requires a port to 6.1.
- The SoC watchdog is enabled. No external watchdog is identified in the stock snapshot.

P1 contains the complete eDP-to-LVDS assembly:

- VP1 supplies eDP. VP0 supplies HDMI.
- The stock bridge has no I2C control node. Preserve its four GPIO2_D3 through GPIO2_D6 straps.
- GPIO3_B5 enables panel power. GPIO3_A3 enables the display assembly.
- PWM14 M1 supplies a 25 us backlight period. GPIO3_B6 enables the backlight.
- Inverted PWM replaces the unsupported stock brightness-reversal property.
- The timing uses 150 MHz, 1920x1080 active pixels, and 2187x1140 total pixels.
- Panel delays are 120 ms prepare, 150 ms enable, 300 ms disable, and 120 ms unprepare.

Radxa's SDIO driver supports the observed 5449:0145 and 544a:0146 device IDs.
Use its paired firmware through the existing radxa-aic8800 extension.
Firmware equivalence with Android remains unverified.

Stock GT9xx and OV5648 nodes lack bound drivers in the collected snapshot.
They are not enabled here. The observed USB touchscreen uses the USB HID driver.
Unused DSI, CSI, PCIe, and SPI devices remain disabled.
The disabled PIR node preserves the stock private binding and KEY_POWER mapping.

Build validation does not establish hardware operation.
Boot, display, audio, radio, suspend, and thermal behavior require board tests.
