# 自用设备支持状态

| 设备                       | 源码状态    | 持有状态    | 启动类型                                   |
|---------------------------|------------|------------|-------------------------------------------|
| BesTV R3300-L             | 已提交上游   | 持有        | mainline U-Boot                          |
| CAINIAO CNIoT-CORE        | 已提交上游   | 不再持有    | mainline U-Boot                          |
| KICKPI K3B                | 已提交上游   | 持有        | mainline U-Boot                          |
| Lenovo Legion Y700 Gen4   | 已提交上游   | 持有        | XBL/ABL + Project Aloha/GRUB             |
| CAINIAO LEMO XIAOC        | 本仓库      | 不再持有    | mainline U-Boot                          |
| CAINIAO XiaoYi Pro        | 本仓库      | 持有        | vendor U-Boot (secure boot)              |
| GOODMOBI A02              | 本仓库      | 持有        | mainline U-Boot                          |
| Elo Backpack5 RK3588S     | 本仓库      | 持有        | mainline U-Boot                          |
| DAMO Cockpit8250          | 本仓库      | 持有        | XBL/ABL or U-Boot/GRUB                   |
| CoreLab TVPro T7 8G Version      | 本仓库      | 持有         | compile from retro98boy/coreelec-u-boot |
| AOC 65T33Z T7 4G Version  | 本仓库      | 持有         | compile from retro98boy/coreelec-u-boot |
| OneThing Cloud OES        | 本仓库      | 不再持有     | vendor U-Boot (secure boot)              |
| OneThing Cloud OES Plus   | 本仓库      | 持有        | vendor U-Boot (secure boot)              |
| SMART AM40                | 已提交上游   | 持有        | mainline U-Boot                          |
| NORCO EMB-3531            | 已提交上游   | 持有        | mainline U-Boot                          |
| Xerox ET1020              | 本仓库      | 持有         | mainline U-Boot                          |
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

<h2 align="center">
  <a href=#><img src="https://raw.githubusercontent.com/armbian/.github/master/profile/logosmall.png" alt="Armbian logo"></a>
  <br><br>
</h2>

# Armbian Linux Build Framework

## Purpose of This Repository

The **Armbian Linux Build Framework** builds customizable OS images based on **Debian** or **Ubuntu** for **single-board computers (SBCs)** and other embedded devices. It assembles the kernel, bootloader, firmware, device trees and root filesystem into a reproducible image, with per-board and per-family configuration.

> **Looking for prebuilt images?** Use [Armbian Imager](https://github.com/armbian/imager/releases) — the easiest way to download and flash Armbian to an SD card or USB drive. Available for Linux, macOS and Windows.

## Quick Start

```bash
git clone https://github.com/armbian/build
cd build
./compile.sh
```

<a href="#armbian-linux-build-framework"><img src=".github/README.gif" alt="Build demonstration" width="100%"></a>

The entrypoint `compile.sh` dispatches into the framework in `lib/`. Build-time options can be passed on the command line, e.g.:

```bash
./compile.sh BOARD=orangepi5 BRANCH=current RELEASE=trixie BUILD_MINIMAL=yes KERNEL_CONFIGURE=no
```

## Build Host Requirements

### Hardware

- **RAM:** ≥ 8 GB (less with `KERNEL_BTF=no`)
- **Disk:** ~50 GB free space
- **Architecture:** x86_64, aarch64 or riscv64

### Operating System

- **Native builds:** Armbian / Debian 13 (Trixie)
- **Containerized:** any Docker-capable Linux
- **Windows:** WSL2 with Armbian / Debian 13 (Trixie)

### Software

- Superuser privileges (`sudo` or root)
- An up-to-date host (outdated Docker or other tooling can cause failures)

## Repository Layout

| Path | Contents |
|:--|:--|
| `compile.sh` | Build entrypoint; sources `lib/single.sh` and invokes the CLI |
| `lib/` | Core build framework (Bash functions, Python helpers in `lib/tools/`) |
| `config/` | Board, family, distribution, kernel and CLI configuration |
| `config/boards/` | One file per board; the extension marks its support status (see below) |
| `config/distributions/` | Supported Debian/Ubuntu release metadata |
| `config/cli/` | CLI package selections per release |
| `patch/` | Kernel, U-Boot and ATF patch sets organized by family/version |
| `packages/` | In-tree package sources, blobs and BSP material |
| `extensions/` | Optional build extensions enabled via `ENABLE_EXTENSIONS=` |
| `tools/` | Developer helpers (`mk_format_patch`, `unifying_configs`) |
| `action.yml` | GitHub Action definition ("Rebuild Armbian") |

### Board config extensions

Files under `config/boards/` use an extension that signals support status:

| Extension | Meaning |
|:--|:--|
| `.conf` | Standard board configuration |
| `.csc` | Community maintained / unstable (no active Armbian maintainer) |
| `.wip` | Work in progress |
| `.eos` | End of life |
| `.tvb` | TV box, community supported (no Armbian maintainer) |

See [`config/boards/README.md`](config/boards/README.md) for the full list of per-board variables (e.g. `BOARD_NAME`, `BOARDFAMILY`, `BOOTCONFIG`, `KERNEL_TARGET`, `SERIALCON`, `MODULES`, `DEFAULT_OVERLAYS`).

Release/package base statuses used under `config/distributions/` are defined separately in [`config/distributions/README.md`](config/distributions/README.md).

## Built With

- **Bash** — build framework in `lib/`, entrypoint `compile.sh`, most of `extensions/` and the shell portions of board/family configs
- **Python** — developer and build helpers under `lib/tools/` (e.g. `patching.py`, `aggregation.py`, `lib/tools/info/`)
- **Make / Kbuild** — kernel and U-Boot build systems invoked by the framework; overlay `Makefile`s under `patch/kernel/archive/*/overlay/`
- **Device Tree Source** (`.dts` / `.dtsi` / `.dtso`) — board/overlay sources carried under `patch/`
- **GitHub Actions** (YAML) — repository automation under `.github/workflows/`
- **Patch series** — thousands of `*.patch` files under `patch/` applied to kernel, U-Boot and ATF trees

## Continuous Integration

Repository automation (board/maintainer data sync, labeling, security scanning, artifact builds, mirroring, etc.) lives in `.github/workflows/`. For a live overview of workflow runs and status, see:

👉 **[CI overview for `armbian/build`](https://actions.armbian.com/?repo=build)**

Self-hosted runner setup notes live in [`.github/workflows/README.md`](.github/workflows/README.md).

## Using the GitHub Action

This repository publishes a composite action (`action.yml`, "Rebuild Armbian") that can be consumed from other workflows to build an image or a kernel.

| Input | Required | Default |
|:--|:--|:--|
| `armbian_token` | yes | — |
| `armbian_target` | no | `kernel` |
| `armbian_board` | no | `uefi-x86` |
| `armbian_branch` | no | `main` |
| `armbian_kernel_branch` | no | `current` |
| `armbian_release` | no | `noble` |
| `armbian_ui` | no | `minimal` |
| `armbian_compress` | no | `sha,img,xz` |
| `armbian_extensions` | no | *(empty)* |
| `armbian_artifacts` | no | `build/output/images/` |

See `action.yml` for the full input list (versioning, signing, publishing and release-metadata options).

## Contributing

Contributions are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to report issues, how to prepare patches (including the `./compile.sh CREATE_PATCHES="yes"` flow) and the PR / labeling conventions. The `.github/labels.yml` file is the source of truth for labels.

## Resources

- **[Documentation](https://docs.armbian.com/Developer-Guide_Overview/)** — building, configuring and customizing
- **[Website](https://www.armbian.com)** — news, features and supported boards
- **[Blog](https://blog.armbian.com)** — development updates and technical articles
- **[Forums](https://forum.armbian.com)** — community support and discussion

## Support

### Community Forums

👉 [forum.armbian.com](https://forum.armbian.com)

### Real-time chat

👉 [Community chat (IRC / Discord)](https://docs.armbian.com/Community_IRC/)

### Paid consultation

For commercial projects, guaranteed response times, or advanced needs, paid support is available from Armbian maintainers.
👉 [Contact us](https://www.armbian.com/contact)

## Contributors

Thank you to everyone who has contributed to Armbian.

<a href="https://github.com/armbian/build/graphs/contributors">
  <img alt="Contributors" src="https://contrib.rocks/image?repo=armbian/build" />
</a>

See also [`CREDITS.md`](CREDITS.md).

## Armbian Partners

Our [partnership program](https://forum.armbian.com/subscriptions) supports Armbian's development and community. Learn more about [our Partners](https://armbian.com/partners).

## License

Released under the **GNU General Public License v2.0**. See [`LICENSE`](LICENSE) for the full text.
