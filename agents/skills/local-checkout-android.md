---
name: local-checkout-android
description: >-
  Navigates the local Android main branch checkout at ~/android/main and downstream Kleaf
  kernel checkouts at ~/android/android*. Use when working on or referencing Android
  platform, Android Desktop boards & follower variants, graphics/display HALs, runtime
  firmware services, or Android kernels (often paired with AP/EC/GSC firmware from
  local-checkout-chromeos).
---

# Android Platform (`~/android/main`) & Kernels (`~/android/android*`)

`~/android/main` is the local Android `main` `repo` checkout, with Kleaf kernel checkouts alongside it at `~/android/android*` (typically named `android<ver>-<kver>-desktop-<target>`; expand `~` to the user's home directory when calling `read_file`).

## Workspace & Search Guardrails

- **Cross-project read-only:** When launched from another workspace, treat `~/android/main` and `~/android/android*` strictly as **read-only** unless explicitly asked to edit them.
- **Cross-checkout AP/EC/GSC firmware (`~/chromiumos`):** Android Desktop boards build AP (`coreboot`, `depthcharge`, `vboot`, `TF-A`), EC (`zephyr`), and GSC (`ti50`) firmware from `~/chromiumos`—use `local-checkout-chromeos` when investigating bootloader/AP/EC/GSC firmware or firmware↔kernel handoff.
- **Subrepo-scoped git commands:** Both `~/android/main` and `~/android/android*` are large `repo` forests with huge `out/`, `bazel-*`, and `prebuilts/` trees. **Never** scan `out/`, `bazel-*`, or `prebuilts/` during source searches. Always run `git -C <subrepo_path> grep -n '<pattern>'` inside the specific git subrepo.
- **Repo-local customizations:** Launching Jetski directly inside `~/android/main` also loads its built-in `.agents` / `.gemini` customizations (`build`, `atest`, `aconfig`, `alint`, `xrefs`, etc.).

## 1. Platform Checkout (`~/android/main`)

### AOSP Subrepos
- **Graphics, Display & Vulkan**:
  - `frameworks/native` — Vulkan loader (`vulkan/`), `services/surfaceflinger/`, `libs/renderengine/`, `libs/gui/`, `libs/ui/` (`GraphicBuffer`, `AHardwareBuffer`).
  - `frameworks/base` (`libs/hwui/`, `core/jni/`, `cmds/`), `frameworks/av`.
  - HAL interfaces: `hardware/interfaces` (`graphics/{allocator,mapper,composer,common}/`), `hardware/libhardware`, `hardware/google/interfaces`, `hardware/google/gfxstream`.
  - External graphics/DRM/Vulkan: `external/drm_hwcomposer`, `external/minigbm`, `external/libdrm`, `external/mesa3d`, `external/vulkan-{headers,validation-layers,utility-libraries,profiles,shader-profiler}`, `external/angle`, `external/skia`, `external/virglrenderer`, `external/rust/rutabaga_gfx`.
- **Core System, Memory, Boot & Build**:
  - `bionic`, `system/core`, `system/libbase`, `system/logging`, `system/memory/{libdmabufheap,libmeminfo,lmkd,mmd}`, `system/{sepolicy,vold,fs/fs_mgr,linkerconfig,libvintf,libueventd-rs,security,bpf}`, `external/avb`, `bootable/recovery`, `packages/modules/adb`, `build/{make,soong}`, `device/google/cuttlefish`.
- **Test Suites & Harness**:
  - `cts`, `external/deqp`, `test/{graphics,vts,suite_harness}`, `tools/tradefederation/core`.

## 2. Kernel Checkouts (`~/android/android*`)

- Run `ls -d ~/android/android*` to list local Kleaf checkouts, and inspect `<checkout>/.repo/manifests/default.xml` to confirm the manifest branch.
- Compare downstream kernel changes against mainline Linux via `~/projects/linux` (`local-checkout-linux`).

## Access Troubleshooting

- If reading `~/android` from another workspace prompts or is blocked, ask the user to grant `read_file(~/android)` (with `~` expanded to the literal home path) in `/permissions`.
