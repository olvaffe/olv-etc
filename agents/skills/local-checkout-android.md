---
name: local-checkout-android
description: >-
  Navigates the local Android main branch checkout at ~/android/main and downstream Kleaf
  kernel checkouts at ~/android/android<version>-<kernel>-<board>. Use when working on or
  referencing Android platform, graphics/display HALs, board configs, or Android kernels.
---

# Android Platform (`~/android/main`) & Kernels (`~/android/android*`)

`~/android/main` is the local Android `main` `repo` checkout, with Kleaf kernel checkouts alongside it at `~/android/android<version>-<kernel>-<board>` (expand `~` to the user's home directory when calling `read_file`).

## Workspace & Search Guardrails

- **Cross-project read-only:** When launched from another workspace, treat `~/android/main` and `~/android/android*` strictly as **read-only** unless explicitly asked to edit them.
- **Subrepo-scoped git commands:** Both `~/android/main` and `~/android/android*` are large `repo` forests with huge `out/`, `bazel-*`, and `prebuilts/` trees. **Never** scan `out/`, `bazel-*`, or `prebuilts/` during source searches (except targeted AIDL/HIDL generated headers under `~/android/main/out/soong/.intermediates/hardware/interfaces/graphics/`). Always run `git -C <subrepo_path> grep -n '<pattern>'` inside the specific git subrepo.
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

## 2. Kernel Checkouts (`~/android/android<version>-<kernel>-<board>`)

- Kleaf/Bazel multi-repo kernel trees live at `~/android/android<version>-<kernel>-<board>` (`tools/bazel`, `build/kernel/kleaf/`, `common/`, `common-modules/`).
- Compare downstream kernel changes against mainline Linux via `~/projects/linux` (`local-checkout-linux`).

## Access Troubleshooting

- If reading `~/android` from another workspace prompts or is blocked, ask the user to grant `read_file(~/android)` (with `~` expanded to the literal home path) in `/permissions`.
