# 自用设备支持状态

| 设备                       | 源码状态    | 持有状态    | 启动类型                                   |
|---------------------------|------------|------------|-------------------------------------------|
| BesTV R3300-L             | 已提交上游   | 持有        | mainline U-Boot                          |
| CAINIAO CNIoT-CORE        | 已提交上游   | 不再持有    | mainline U-Boot                          |
| CAINIAO LEMO XIAOC        | 本仓库      | 不再持有    | mainline U-Boot                          |
| CAINIAO XiaoYi Pro        | 本仓库      | 持有        | vendor U-Boot (secure boot)              |
| GOODMOBI A02              | 本仓库      | 持有        | mainline U-Boot                          |
| DAMO Cockpit8250          | 本仓库      | 持有        | XBL/ABL or U-Boot/GRUB                   |
| CoreLab TVPro T7 8G Version      | 本仓库      | 持有         | compile from retro98boy/coreelec-u-boot |
| AOC 65T33Z T7 4G Version  | 本仓库      | 持有         | compile from retro98boy/coreelec-u-boot |
| OneThing Cloud OES        | 本仓库      | 不再持有     | vendor U-Boot (secure boot)              |
| OneThing Cloud OES Plus   | 本仓库      | 持有        | vendor U-Boot (secure boot)              |
| SMART AM40                | 已提交上游   | 持有        | mainline U-Boot                          |
| NORCO EMB-3531            | 已提交上游   | 持有        | mainline U-Boot                          |
| TIANNUO TN3399_V3         | 本仓库      | 不再持有      | mainline U-Boot                         |

# 下载

[最新镜像](https://github.com/retro98boy/armbian-build/releases/tag/latest-release)

[最新deb](https://github.com/retro98boy/armbian-build/releases/tag/latest-deb)

# 如何更新

正常使用apt命令更新一般软件包

本仓库维护的设备不在Armbian/Ubuntu存储库中，所以需要去本仓库发布界面下载最新deb手动安装，包括内核和每个设备的私有deb

# 源码对比

[retro98boy/armbian-build:main <- armbian/build:main](https://github.com/retro98boy/armbian-build/compare/main...armbian:build:main)

[armbian/build:main <- retro98boy/armbian-build:main](https://github.com/armbian/build/compare/main...retro98boy:armbian-build:main)

# Original README

<h3 align="center">
  <a href=#><img src="https://raw.githubusercontent.com/armbian/.github/master/profile/logosmall.png" alt="Armbian logo"></a>
  <br><br>
</h3>

## Purpose of This Repository

The **Armbian Linux Build Framework** creates customizable OS images based on **Debian** or **Ubuntu** for **single-board computers (SBCs)** and embedded devices.

It builds a complete Linux system including kernel, bootloader, and root filesystem, giving you control over versions, configuration, firmware, device trees, and system optimizations.

The framework supports **native**, **cross**, and **containerized** builds for multiple architectures (`x86_64`, `aarch64`, `armhf`, `riscv64`) and is suitable for development, testing, production, or automation.

> **Looking for prebuilt images?** Use [Armbian Imager](https://github.com/armbian/imager/releases) — the easiest way to download and flash Armbian to your SD card or USB drive. Available for Linux, macOS, and Windows.

## Quick Start

```bash
git clone https://github.com/armbian/build
cd build
./compile.sh
```

<a href="#how-to-build-an-image-or-a-kernel"><img src=".github/README.gif" alt="Build demonstration" width="100%"></a>

## Build Host Requirements

### Hardware
- **RAM:** ≥8GB (less with `KERNEL_BTF=no`)
- **Disk:** ~50GB free space
- **Architecture:** x86_64, aarch64, or riscv64

### Operating System
- **Native builds:** Armbian or Ubuntu 24.04 (Noble)
- **Containerized:** Any Docker-capable Linux
- **Windows:** WSL2 with Armbian/Ubuntu 24.04

### Software
- Superuser privileges (`sudo` or root)
- Up-to-date system (outdated Docker or other tools can cause failures)

## Resources

- **[Documentation](https://docs.armbian.com/Developer-Guide_Overview/)** — Comprehensive guides for building, configuring, and customizing
- **[Website](https://www.armbian.com)** — News, features, and board information
- **[Blog](https://blog.armbian.com)** — Development updates and technical articles
- **[Forums](https://forum.armbian.com)** — Community support and discussions

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting issues, submitting changes, and contributing code.

## Support

### Community Forums
Get help from users and contributors on troubleshooting, configuration, and development.
👉 [forum.armbian.com](https://forum.armbian.com)

### Real-time Chat
Join discussions with developers and community members on IRC or Discord.
👉 [Community Chat](https://docs.armbian.com/Community_IRC/)

### Paid Consultation
For commercial projects, guaranteed response times, or advanced needs, paid support is available from Armbian maintainers.
👉 [Contact us](https://www.armbian.com/contact)

## Contributors

Thank you to everyone who has contributed to Armbian!

<a href="https://github.com/armbian/build/graphs/contributors">
  <img alt="Contributors" src="https://contrib.rocks/image?repo=armbian/build" />
</a>

## Armbian Partners

Our [partnership program](https://forum.armbian.com/subscriptions) supports Armbian's development and community. Learn more about [our Partners](https://armbian.com/partners).
