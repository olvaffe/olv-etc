---
name: local-checkout-mesa
description: >-
  Navigates the local upstream Mesa 3D checkout at ~/projects/mesa with a focus on
  Vulkan development (common vk_* runtime, WSI, SPIR-V/NIR, PanVK/Mali, Turnip/Adreno,
  plus ANV/Intel and RADV/AMD) and occasional Gallium/EGL/OpenGL follow-up.
  Use when working on or referencing Mesa.
---

# Upstream Mesa 3D (`~/projects/mesa`)

`~/projects/mesa` is the local upstream Mesa checkout (expand `~` to the user's home directory when calling `read_file`).

## Workspace, Build & Policy Guardrails

- **Cross-project read-only:** When your active workspace is another repo (Android, ChromiumOS, Linux, Vulkan-Docs), treat `~/projects/mesa` strictly as **read-only** unless explicitly asked to edit it. Run `git -C ~/projects/mesa status -sb` first to see the active branch and any local WIP changes.
- **Upstream AI contribution policy (`~/projects/mesa/AGENTS.md`):**
  - Never open merge requests or post comments on upstream GitLab.
  - Upstream commits require `Generated-by: LLM` or `Assisted-by: LLM` trailers when applicable, and `AGENTS.md` / `docs/drivers/panfrost.rst` restrict AI-generated code edits in `src/panfrost/`, `src/gallium/drivers/panfrost/`, `src/poly/`, `src/intel/compiler/jay/`, `src/nouveau/`, `src/asahi/`, and `src/imagination/` (code analysis, log review, and patch sanity-checking are permitted).
- **Local cross files & build directories:**
  - `*.ini` at the repo root are local Meson cross files.
  - `out/` and `out-*/` are local Meson build directories—**never scan them during source searches**. When you need to check a build's active config or generated sources, inspect `<build-dir>/meson-info/intro-buildoptions.json`, `<build-dir>/compile_commands.json`, or `<build-dir>/src/`.

## Fast Lookup Idioms (Avoid 0-Hit Searches!)

### 1. Finding a Vulkan Entrypoint (`vkFoo` -> Driver Function)
Mesa strips the `vk` prefix and dispatches through generated tables. Searching `vkCmdDraw` or `panvk_v13_CmdDraw` directly will miss definitions—search the bare `<EntryPoint>` name (e.g. `CmdDraw`, `CreateGraphicsPipelines`) or the driver's dispatch macro:

| Layer / Driver | Prefix & Multi-Gen Entrypoint Pattern | Where to Search (`git -C ~/projects/mesa grep -n ...`) |
| :--- | :--- | :--- |
| **Common Runtime** | `vk_common_<EntryPoint>` (fallback for many 1.1–1.4 cmds!) | `src/vulkan/runtime/` |
| **PanVK (Mali)** | `panvk_<EntryPoint>` or `panvk_per_arch(<EntryPoint>)` (`PAN_ARCH` 6,7,10–14) | `src/panfrost/vulkan/` (inc. `csf/` & `jm/`) |
| **Turnip (Adreno)** | `tu_<EntryPoint>` or `template <chip CHIP> ... <EntryPoint>` + `TU_GENX(<EntryPoint>)` | `src/freedreno/vulkan/` |
| **ANV (Intel)** | `anv_<EntryPoint>` or `genX(<EntryPoint>)` (`GFX_VERx10` 90–300) | `src/intel/vulkan/` |
| **RADV (AMD)** | `radv_<EntryPoint>` | `src/amd/vulkan/` |

### 2. Generated Headers & Hardware XML (Not in `git grep` as `.h`)
Many Mesa structs, packers, and opcodes are generated at build time. Read the generator inputs in git (or inspect materialized outputs under `out/src/` or `out-*/src/` when present):
- **Vulkan dispatch, cmd queue, features, properties & SPIR-V caps**: `src/vulkan/util/vk_*_gen.py` + `src/vulkan/registry/vk.xml`
- **NIR opcodes, intrinsics & algebraic rules**: `src/compiler/nir/nir_opcodes.py`, `nir_intrinsics.py`, `nir_opt_algebraic.py`
- **Mali (`panfrost`) hardware descriptors & CSF opcodes**: `src/panfrost/genxml/v{6,7,9,10,11,12,13,14}.xml` + `common.xml` (`v6`/`v7` = Bifrost, `v9`–`v11` = Valhall, `v12` = G720, `v13` = G725/Krake, `v14` = G1)
- **Adreno (`freedreno`) registers, descriptors, PM4 & ISA**: `src/freedreno/registers/adreno/{a6xx,a7xx,a8xx}*.xml`, `adreno_pm4.xml`, and `src/freedreno/isa/ir3-*.xml`
- **Intel & AMD hardware defs**: `src/intel/genxml/{gen120,gen125,xe2,xe3}*.xml`; `src/amd/registers/{gfx10,gfx103,gfx11,gfx115,gfx12,pkt3}.json`

## Prioritized Subsystem Map

### 1. Core Vulkan Infrastructure & Compiler
- **Common Vulkan Runtime** (`src/vulkan/runtime/`): Base objects (`vk_instance`, `vk_physical_device`, `vk_device`, `vk_queue`, `vk_command_buffer`, `vk_image`, `vk_pipeline`, `vk_shader`, `vk_descriptors`), dynamic rendering/graphics state (`vk_graphics_state.c`), sync (`vk_sync*.c`, `vk_drm_syncobj.c`), Android AHB/sync (`vk_android.c`), `vk_meta*`, and `bvh/`.
- **Vulkan WSI** (`src/vulkan/wsi/`): `wsi_common.c`, `wsi_common_drm.c`, `wsi_common_wayland.c`, `wsi_common_x11.c`, `wsi_common_headless.c`.
- **SPIR-V -> NIR & NIR Passes**: `src/compiler/spirv/` (`spirv_to_nir.c`, `vtn_*.c`) and `src/compiler/nir/` (`nir.h`, `nir_builder.h`, `nir_lower_*.c`, `nir_opt_*.c`).
- **Kernel UAPI Headers**: `include/drm-uapi/` (`panthor_drm.h`, `panfrost_drm.h`, `msm_drm.h`, `xe_drm.h`, `i915_drm.h`, `amdgpu_drm.h`).

### 2. Primary Hardware: Arm Mali (`src/panfrost/`) & Qualcomm Adreno (`src/freedreno/`)
- **Arm Mali — PanVK & Shared Stack (`src/panfrost/`)**:
  - `vulkan/` — `panvk_*.c/h`, per-arch `panvk_vX_*.c`, **CSF backend (`v10+`)** in `vulkan/csf/` (`panvk_vX_cmd_buffer.c`, `cmd_draw.c`, `cmd_dispatch.c`, `gpu_queue.c`, `exception_handler.c`), **JM backend (`v6–v7`)** in `vulkan/jm/`, Android integration (`panvk_android.c`).
  - `lib/` — Shared descriptors, formats, AFBC/AFRC, tiling & FB setup (`pan_desc.c`, `pan_format.c`, `pan_layout.c`, `pan_afbc.c`, `pan_afrc.h`, `pan_texture.c`, `pan_fb.c`, `pan_tiler.c`, `pan_props.c`), plus kernel UAPI backends in `lib/kmod/` (`panthor_kmod.c`, `panfrost_kmod.c`, `virtio/`).
  - `libpan/` & `src/poly/` — OpenCL C (`*.cl`) on-GPU helper shaders (indirect draws/dispatches, copies, queries, geometry/tessellation).
  - `compiler/` — Shared `pan_nir_*.c` passes, `bifrost/` (`bi_*` C backend for Bifrost/Valhall), `valhall/` (`va_*`), and `kraid/` (Rust compiler & `isa-v9-v14.xml` / `isa-v15.xml` for Valhall / 5th Gen).
  - `genxml/` — XML defs, `cs_builder.h` (CSF command emission), and CSF/JM command stream decoders (`decode_csf.c`, `decode_jm.c`).
- **Qualcomm Adreno — Turnip & Shared Stack (`src/freedreno/`)**:
  - `vulkan/` — `tu_*.cc/h` (`tu_cmd_buffer.cc`, `tu_pipeline.cc`, `tu_shader.cc`, `tu_descriptor_set.cc`, `tu_dynamic_rendering.cc`, `tu_clear_blit.cc`, `tu_lrz.cc`, `tu_image.cc`, `tu_formats.cc`, `tu_cs.cc`), plus kernel backends (`tu_knl_drm_msm.cc`, `tu_knl_drm_virtio.cc`, `tu_knl_kgsl.cc`).
  - `ir3/` & `isa/` — `ir3` shader compiler (`ir3_compiler_nir.c`, `ir3_nir*.c`, RA, scheduling, delay slots, a6xx/a7xx/a8xx features) and ISA XMLs.
  - `fdl/` — Image/tile/UBWC & LRZ layout computation (`fd6_layout.c`, `fd6_view.cc`, `fd6_format_table.c`).
  - `common/` & `drm/` — `freedreno_devices.py` (GPU traits/quirks per Adreno chip ID) and DRM/ringbuffer helpers.

### 3. Secondary Hardware Reference: Intel (`src/intel/`) & AMD (`src/amd/`)
- **Intel (ANV)**: `src/intel/vulkan/` (`anv_*.c`, `genX_*.c`, `anv_nir_*.c`, `anv_kmd_backend.c` for i915/Xe), `isl/` (surface/tiling layout), `blorp/` (blits/clears), `compiler/` (`brw/`, `elk/`, `jay/`), `dev/` (`intel_device_info.c`), `genxml/`.
- **AMD (RADV)**: `src/amd/vulkan/` (`radv_*.c`, `nir/`, `meta/`, `bvh/`), `compiler/` (ACO), `common/` (`ac_*`), `addrlib/`, `registers/`.

### 4. Occasional Follow-Up: EGL, GBM, Gallium & OpenGL
- **EGL & GBM**: `src/egl/` (`main/`, `drivers/dri2/platform_{android,wayland,surfaceless,x11}.c`), `src/gbm/`.
- **OpenGL & State Tracker**: `src/mesa/main/` (core GL state/API), `src/mesa/state_tracker/` (`st_*` GL -> Gallium bridge), `src/compiler/glsl/`.
- **Gallium**: `src/gallium/include/pipe/` (`p_screen.h`, `p_context.h`, `p_state.h`, `p_defines.h`), `src/gallium/auxiliary/`, `src/gallium/frontends/dri/`, and GL drivers (`src/gallium/drivers/{panfrost,freedreno,iris,radeonsi,zink}/`).

## Search & Access Tips

- **Fast git search**: Always scope `git -C ~/projects/mesa grep -n '<pattern>' -- src/<subdir>` so searches skip `out/` and `out-*/` and stay focused on the target subsystem.
- **Access troubleshooting**: If accessing `~/projects/mesa` from another workspace prompts or fails, ask the user to grant `read_file(~/projects/mesa)` (with `~` expanded to the literal home path) in `/permissions`.
