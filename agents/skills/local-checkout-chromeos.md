---
name: local-checkout-chromeos
description: >-
  Navigates the local ChromiumOS repo checkout at ~/chromiumos with primary focus on
  Ti50-NT GSC firmware & tools (platform/ti50, gsc-utils, hdctools/servo), Zephyr EC
  firmware (platform/ec/zephyr & zephyrproject), and AP firmware & verified boot (coreboot,
  vboot_reference, depthcharge, avb, TF-A) — often paired with Android kernel & userspace
  (local-checkout-android) or upstream Linux (local-checkout-linux) — plus Portage
  overlays/ebuilds, ChromeOS graphics/kernel (mesa, minigbm, kernel/v6.6), and chromite.
---

# ChromiumOS & Device Firmware Checkout (`~/chromiumos`)

`~/chromiumos` is a full ChromiumOS `repo` checkout whose **AP, EC, and GSC firmwares are often paired with the Android kernel & userspace (`~/android/android*`, `~/android/main`) or the upstream Linux kernel (`~/projects/linux`)** in addition to ChromeOS (expand `~` to the user's home directory when calling `read_file`).

## Workspace & Search Guardrails

- **Cross-project read-only:** When launched from another workspace, treat `~/chromiumos` strictly as **read-only** unless explicitly asked to edit it.
- **Often paired with Android or upstream Linux (`local-checkout-android` / `local-checkout-linux`):** Firmware built from `~/chromiumos` (`coreboot`, `depthcharge`, `vboot_reference`, `TF-A`, `platform/ec`, `platform/ti50`) often boots **Android kernel + Android userspace** (`~/android/android*`, `~/android/main`) or **upstream Linux** (`~/projects/linux`) rather than ChromeOS. Check `local-checkout-android` or `local-checkout-linux` when investigating firmware↔kernel handoff, runtime firmware tools/HALs, or board/DT configs unless ChromeOS is clearly targeted.
- **Subrepo-scoped git commands:** `~/chromiumos` contains hundreds of independent git repos plus `chroot/` and `out/`. **Never** scan `chroot/`, `out/`, or the top-level directory recursively—always run `git -C ~/chromiumos/<subrepo> grep -n '<pattern>'` (or `git log` / `git ls-files`) directly inside the target git subrepo.
- **Resolving internal subrepos dynamically:** Public subrepos are listed in `~/chromiumos/.repo/manifests/full.xml` and internal subrepos in `~/chromiumos/.repo/manifests/internal_full.xml`. When looking up internal components, query `internal_full.xml` to find the exact subrepo paths and check any repo-local `GEMINI.md` / `AGENTS.md` files inside them. Never copy code or configs from internal/private repos into public upstream repositories.

## 1. Primary Focus: Firmware, Security & Hardware Debug

### GSC (Ti50-NT) Firmware & Host Tools
- **Ti50-NT Firmware**:
  - Source subrepos live under `~/chromiumos/src/platform/ti50/` — `common/` (`applications/`, `capsules/`, `libs/`, `hw_configs/`, `projects/`; has `GEMINI.md`) and `ports/tpm2_server/`.
  - Prebuilt release images (`ti50-nt.bin.{prod,prepvt}`) are packaged by `chromeos-base/chromeos-ti50` in `~/chromiumos/src/third_party/chromiumos-overlay/`.
- **GSC Host Tools (`gsctool`, AP RO verification, CCD)**: `~/chromiumos/src/platform/gsc-utils/`
  - `extra/usb_updater/` — `gsctool.c` (fw update, CCD open/lock/capabilities, board ID, factory mode) and `verify_ro.c`.
  - `util/` — helper scripts (`opentitantool.sh`, `explain_aprov.sh`, `re-sign-gsc.sh`, `maptty.sh`), plus `boot_param/`.
- **Servo, CCD & Debug Control (`hdctools`)**: `~/chromiumos/src/third_party/hdctools/` (has `GEMINI.md`)
  - `servo/data/` — `servod` configs (`ccd_ti50.xml`, `c2d2.xml`, `<board>_*.xml` / `*_inas.py`).
  - `servo/drv/` — control drivers (`cr50.py` [shared GSC console driver], `fw_wp_ccd.py`, `ec.py`, `ap.py`, `futility_gbb.py`, `cros_ec_*_power.py`) and `ec3po/` console mux.

### EC Firmware (Zephyr-Based)
- **Zephyr EC (`zmake`)**: `~/chromiumos/src/platform/ec/` (read `AGENTS.md` when diving deep) + upstream Zephyr RTOS in `~/chromiumos/src/third_party/zephyrproject/zephyr/`:
  - Board/project configs & DT overlays: `zephyr/program/<program>/<board>/` (`project.conf`, `project.overlay`, `BUILD.py`, GPIO/I2C/USBC/power/sensor DTS; built via `zephyr/zmake/`). *(Tip: `git -C ~/chromiumos/src/platform/ec ls-files '*<board>*'` quickly maps any variant `<board>` to its `<program>`.)*
  - Zephyr shims, drivers & subsystems: `zephyr/{app,drivers,dts,include,shim,subsys,boards}/`.
  - Shared C EC code & host tools: `{common,driver,power,include,crypto}/` and `util/` (`ectool.cc`).

### AP (Application Processor) Firmware & Verified Boot
- **Coreboot (ROM/ramstage, silicon & mainboard init, CBMEM/coreboot tables, `fw_config`, FMAP)**: `~/chromiumos/src/third_party/coreboot/`
  - **Mainboard & variant layouts (two conventions — grep `<board>` in `src/mainboard/google/**/Kconfig.name` when resolving a variant to `<program>`):**
    - **Variant subdirectories**: `src/mainboard/google/<program>/variants/<board>/` (`overridetree.cb`, GPIO tables, memory/SPD, `fw_config.c`).
    - **Flat program directories**: `src/mainboard/google/<program>/` (derivative `<board>` models configured via `BOARD_GOOGLE_<BOARD>` in `Kconfig` / `Kconfig.name` without a `variants/` subdir).
  - SoC, OS tables & drivers: `src/soc/{intel,amd,mediatek,qualcomm,rockchip}/`, `src/lib/coreboot_table.c` & `src/commonlib/bsd/include/commonlib/bsd/cbmem_id.h` (coreboot table / CBMEM handoff), `src/drivers/`, `src/ec/google/chromeec/`, `src/security/vboot/`.
  - Companion public firmware repos: `~/chromiumos/src/third_party/arm-trusted-firmware/` (BL31 `plat/{mediatek,qti,rockchip}/`).
- **Verified Boot & Signing (`vboot_reference`)**: `~/chromiumos/src/platform/vboot_reference/`
  - `firmware/2lib/` (`vb2_*` RO/RW firmware & kernel verification, `2nvstorage`, `2secdata*`), `firmware/avb/` (vboot-to-AVB glue), and `host/`.
  - `futility/` — `futility` host/DUT tool (`cmd_gbb_utility.c`, `cmd_gscvd.c` for GSC Verified Descriptor AP RO verification, `cmd_sign.c`, `cmd_update.c`, `cmd_dump_fmap.c`) and `cgpt/`.
- **Depthcharge (vboot payload, fastboot & kernel/OS handoff)**: `~/chromiumos/src/platform/depthcharge/`
  - Board & variant configs: `src/board/<program>/` (`board.c`, `<board>.c`) and `configs/config.<board>`.
  - **Kernel / OS handoff (`src/boot/`)**: `fit.c`, `dt_util.c`, `commandline.c`, `ramoops.c`, `coreboot.c`, `bootconfig.c`, `android_bootconfig_params.c`, `android_dtboimg.c`, `android_pvmfw.c`, `android_mte.c`, `android_vpd.h`.
  - Verification stages, fastboot & drivers: `src/vboot/` (`stages.c`, `load_kernel.c`, `secdata_tpm.c`, `callbacks/`, `ui/`), `src/fastboot/` (`cmd.c`, `vars.c`, `disk.c`, `usb.c`, `tcp.c`), `src/drivers/{storage,tpm,bus,ec,soc,video,power,gpio}/`.
- **Android Verified Boot (`avb`)**: `~/chromiumos/src/aosp/external/avb/` (`libavb/`, `libavb_cert/`, `avbtool.py`).
- **SPI Flash Programmer**: `~/chromiumos/src/third_party/flashrom/`.

## 2. Portage Overlays, Ebuilds & Build Tooling

### Overlay Precedence (Lowest -> Highest)
1. `~/chromiumos/src/third_party/portage-stable/` — Upstream Gentoo ebuilds.
2. `~/chromiumos/src/third_party/eclass-overlay/` — Shared eclasses (`cros-workon.eclass`, `cros-firmware.eclass`, `cros-ec.eclass`, `cros-kernel2.eclass`).
3. `~/chromiumos/src/third_party/chromiumos-overlay/` — First-party ChromiumOS ebuilds:
   - Firmware/GSC/EC: `sys-boot/{coreboot,depthcharge,chromeos-bootimage,edk2,crdyboot}/`, `chromeos-base/{chromeos-ec,ec-utils,vboot_reference,chromeos-ti50,chromeos-gsc-dev}/`, `dev-util/hdctools/`.
   - Graphics & Kernel: `media-libs/{mesa,mesa-iris,mesa-radv,mesa-amd,mesa-freedreno,mesa-panfrost,minigbm}/`, `sys-kernel/chromeos-kernel-6_6/` (and `5_10`, `5_15`, `6_1`, `6_12`).
4. `~/chromiumos/src/overlays/` (`baseboard-*`, `chipset-*`, `overlay-<board>/`) and `~/chromiumos/src/private-overlays/` (`chipset-*-private/`, `overlay-<board>-private/` — `make.conf`, `profiles/base/package.use`, firmware/BSP ebuilds), alongside Boxster hardware configs in `src/program/`, `src/project_public/`, `src/project/`, and partner trees under `src/partner_private/`.

### Workflow Tools (`chromite` & `depot_tools`)
- `~/chromiumos/chromite/` (`bin/cros_sdk`, `bin/cros`, `bin/cros-workon`, `bin/cros_workon_make`, `lib/`, `api/`) and chroot scripts in `~/chromiumos/src/scripts/`.
- `~/chromiumos/depot_tools/` (`repo`, `cros format` / Gerrit upload helpers).

## 3. ChromeOS Graphics & Kernel Subrepos

- **ChromeOS Kernel (primarily `v6.6`)**: `~/chromiumos/src/third_party/kernel/v6.6/` (with sibling trees `v5.10`, `v5.10-arcvm`, `v5.15`, `v6.1`, `v6.12`). *(When firmware is paired with Android or upstream Linux rather than ChromeOS, use `~/android/android*` in `local-checkout-android` or `~/projects/linux` in `local-checkout-linux`.)*
- **Mesa & Buffer Allocation**: `~/chromiumos/src/third_party/mesa/` (plus vendor-pinned branches `mesa-iris`, `mesa-radv`, `mesa-amd`, `mesa-freedreno`, `mesa-arcvm`, `mesa-img`, `mesa-reven`), `~/chromiumos/src/platform/minigbm/`, and `~/chromiumos/src/platform/crosvm/`.
- **Access troubleshooting:** If reading `~/chromiumos` from another workspace prompts or fails, ask the user to grant `read_file(~/chromiumos)` (with `~` expanded to the literal home path) in `/permissions`.
