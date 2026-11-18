---
name: local-checkout-linux
description: >-
  Navigates the local upstream Linux kernel checkout at ~/projects/linux with a focus on
  drivers/gpu/drm (panthor >>> msm > xe/i915 > amdgpu/mediatek/rockchip) and supporting
  GPU subsystems (mm/shmem, dma-buf/dma, iommu/io-pgtable, and arm64 DeviceTree/bindings)
  for modern Arm, Intel (MTL+), and AMD (Zen2+/GFX10+) platforms. Use when working on or referencing
  upstream Linux kernel code.
---

# Upstream Linux Kernel (`~/projects/linux`)

`~/projects/linux` is the local upstream Linux kernel checkout (expand `~` to the user's home directory when calling `read_file`).

## Workspace & Build Directory Guardrails

- **Cross-project read-only:** When your active workspace is another repo (Mesa, Android, ChromiumOS), treat `~/projects/linux` strictly as **read-only** unless explicitly asked to modify it. Run `git -C ~/projects/linux status -sb` first to see the active branch or local patch series.
- **Local `O=<DIR>` Kbuild directories:** Uppercase directories at the repo root (containing `.config` / `defconfig`) are local out-of-tree Kbuild build outputs—**never scan them during source searches**. Always pass explicit pathspecs to `git -C ~/projects/linux grep -n '<pattern>' -- <subpaths>`.

## 1. Core DRM Infrastructure (`drivers/gpu/drm/` & `include/drm/`)

Key shared helpers heavily used by modern Vulkan/CSF/VM_BIND drivers:
- **GEM & Shmem**: `drm_gem.c`, `drm_gem_shmem_helper.c` (`include/drm/drm_gem_shmem_helper.h` — backing pages, pin/vmap/mmap/sgt used by `panthor`, `panfrost`, and `virtio`), `drm_gem_dma_helper.c`, `drm_prime.c`.
- **GPUVM, Exec & Sync**: `drm_gpuvm.c` (`include/drm/drm_gpuvm.h` — VA space & `VM_BIND` map/unmap/remap split-merge engine used by `panthor`, `xe`, `msm`), `drm_exec.c` (ww_mutex BO locking loop), `drm_syncobj.c`.
- **GPU Job Scheduler**: `drivers/gpu/drm/scheduler/` (`sched_main.c`, `sched_entity.c`, `sched_fence.c`, `include/drm/gpu_scheduler.h`).
- **TTM** (used by `xe` & `amdgpu`): `drivers/gpu/drm/ttm/` (`ttm_bo.c`, `ttm_resource.c`, `ttm_pool.c`).
- **KMS / Atomic**: `drm_atomic*.c`, `drm_bridge.c`, `drm_fourcc.c` + `include/uapi/drm/drm_fourcc.h` (format modifiers: AFBC, AFRC, UBWC, MediaTek/Intel/AMD tiling).

## 2. Prioritized DRM Drivers (`panthor >>> msm > intel > amd/mtk`)

### Tier 1: Arm Mali CSF — `panthor` (`drivers/gpu/drm/panthor/`, `include/uapi/drm/panthor_drm.h`)
Targets CSF Mali GPUs (Valhall v10+ & 5th Gen v12/v13+, e.g., Mali-G610 on `rk3588`, Mali-G725/G925 on `mt8196`):
- **Entry, IOCTLs & Device Lifecycle**: `panthor_drv.c` (`DEV_QUERY`, `BO_*`, `VM_*`, `GROUP_*`, `TILER_HEAP_*`), `panthor_device.c` (reset, suspend/resume, Clocks/regulators), `panthor_devfreq.c`.
- **Hardware Discovery, GPU & Power Control**: `panthor_hw.c` (arch/product ID feature map), `panthor_gpu.c` + `panthor_gpu_regs.h` (caches, L2 power, coherency), `panthor_pwr.c` + `panthor_pwr_regs.h` (5th Gen / v12+ `PWR_CONTROL` host interface).
- **CSF Firmware & Group Scheduler**: `panthor_fw.c` + `panthor_fw_regs.h` (MCU boot, `GLB`/`CSG`/`CS` input/output blocks, doorbells, IRQs), `panthor_sched.c` (`drm_gpu_scheduler` queues, CSG slot multiplexing, tick/timeslice, suspend/protm, syncobj signaling).
- **Memory, VM/MMU, Tiler Heap & Perf**: `panthor_gem.c` (shmem BOs, kernel BOs), `panthor_mmu.c` + `panthor_mmu_regs.h` (`drm_gpuvm` + `io-pgtable-arm` `ARM_MALI_LPAE` AS management & VM_BIND), `panthor_heap.c` (chunked tiler heap), `panthor_perf.c`.
- *(Older Bifrost Mali-G52 on `mt8186` & `rk3568`)*: Job Manager driver in `drivers/gpu/drm/panfrost/` (`include/uapi/drm/panfrost_drm.h`).

### Tier 2: Qualcomm Adreno — `msm` (`drivers/gpu/drm/msm/`, `include/uapi/drm/msm_drm.h`)
Targets Adreno a6xx (`sc7180` / a618) and a7xx (`x1e80100`, `x1p42100`):
- **Core, GEM, VM & Submit**: `msm_drv.c`, `msm_gpu.c`, `msm_gem.c` (direct shmem + shrinker in `msm_gem_shrinker.c`), `msm_gem_submit.c`, `msm_gem_vma.c` (`drm_gpuvm`), `msm_ringbuffer.c`, `msm_iommu.c` (per-context pagetables / PRR).
- **Adreno GPU & GMU**: `adreno/adreno_device.c`, `adreno/adreno_gpu.c`, `adreno/a6xx_catalog.c` (`sc7180`), `adreno/a7xx_catalog.c` (`x1+`), `adreno/a6xx_gpu.c` (shared a6xx/a7xx bringup, RPTR/WPTR, UCHE/trap, CP init), `adreno/a6xx_gmu.c` + `a6xx_hfi.c` (GMU power/clocks), `adreno/a6xx_preempt.c`, `adreno/a8xx_*`.
- **Display (MDSS)**: `disp/dpu1/` (DPU KMS), `dp/`, `dsi/`.

### Tier 3: Modern Intel (MTL+) — `xe` (`drivers/gpu/drm/xe/`, `include/uapi/drm/xe_drm.h`)
Targets Meteor Lake (Xe-LPG / GFX12.70), Lunar Lake (Xe2), and Panther Lake (Xe3):
- **Compute / Render / GT / VM**: `xe_device.c`, `xe_pci.c`, `xe_bo.c` (TTM), `xe_vm.c` + `xe_pt.c` (`drm_gpuvm` + `VM_BIND`), `xe_exec.c` + `xe_exec_queue.c`, `xe_guc*.c` (GuC submission/PC/CT), `xe_gt*.c`, `xe_hw_engine.c`, `regs/`.
- **Display KMS (shared with `i915`!)**: `xe` compiles display support directly from `drivers/gpu/drm/i915/display/` (`intel_display.c`, `skl_universal_plane.c`, `intel_dp.c`, etc.) via `drivers/gpu/drm/xe/display/`. *(Legacy i915 GT/GEM for MTL comparisons: `drivers/gpu/drm/i915/gt/` & `gem/`.)*

### Tier 4: AMD (Zen2+ / GFX10+) & MediaTek / Rockchip KMS
- **AMD (`drivers/gpu/drm/amd/`, `include/uapi/drm/amdgpu_drm.h`)**: RDNA / GFX10+ platforms (GFX10/10.3 VanGogh/Mendocino/Rembrandt, GFX11/11.5 Phoenix/HawkPoint/Strix, GFX12+):
  - `amdgpu/`: `amdgpu_drv.c`, `amdgpu_object.c`, `amdgpu_vm*.c`, `amdgpu_cs.c`, `amdgpu_userq*.c`, `gfx_v{10,11,12}*.c`, `gmc_v{10,11,12}*.c`, `mes_v{11,12}*.c`, `sdma_v{5,6,7}*.c`.
  - `display/` (Display Core / `amdgpu_dm`, DCN2/3/3.5/4) and `pm/swsmu/` (SMU power management).
- **MediaTek & Rockchip Display KMS** (paired with Mali `panthor`/`panfrost` via PRIME DMA-BUF):
  - `drivers/gpu/drm/mediatek/` (`mt8186`, `mt8196` — `mtk_drm_drv.c`, `mtk_crtc.c`, `mtk_ddp_comp.c`, `mtk_disp_ovl*.c`, `mtk_dp.c`, `mtk_dsi.c`).
  - `drivers/gpu/drm/rockchip/` (`rk3568`, `rk3588` — `rockchip_drm_drv.c`, `rockchip_drm_vop2.c` for VOP2, `dw_hdmi_qp-rockchip.c`, `dw_dp-rockchip.c`, `dw-mipi-dsi2-rockchip.c`).

## 3. Supporting Subsystems (`mm/shmem`, `dma`, `iommu`, `dt`)

- **Memory Management & Shmem (`mm/`)**:
  - `mm/shmem.c` + `include/linux/shmem_fs.h` (tmpfs/shmem folio allocation, swapout, `shmem_read_folio_gfp` used by GEM shmem BOs), `mm/vmscan.c` (shrinkers), `mm/memory.c`, `mm/gup.c`.
- **DMA-BUF, Fences & DMA Mapping**:
  - `drivers/dma-buf/`: `dma-buf.c`, `dma-resv.c`, `dma-fence*.c`, `sync_file.c`, `udmabuf.c`, `heaps/` (`system_heap.c`, `cma_heap.c`) + `include/linux/{dma-buf,dma-resv,dma-fence}.h` & `include/uapi/linux/{dma-buf,dma-heap,udmabuf}.h`.
  - `kernel/dma/`: `mapping.c`, `direct.c`, `swiotlb.c`, `contiguous.c`, `ops_helpers.c` (`dma_map_sgtable`, cache maintenance / non-coherent DMA).
- **IOMMU & IO Page Tables (`drivers/iommu/`)**:
  - Core & DMA glue: `iommu.c`, `dma-iommu.c`, `iova.c`.
  - Page table formats: `io-pgtable-arm.c` (`ARM_64_LPAE_S1` and `ARM_MALI_LPAE` used directly by `panthor_mmu`, `panfrost_mmu`, and `msm`).
  - Platform IOMMUs: `arm/arm-smmu-v3/` (modern ARM64 / `mt8196`), `arm/arm-smmu/arm-smmu-qcom.c` (`sc7180`, `x1+` GPU/MDSS SMMU & context bank split), `mtk_iommu.c` (`mt8186`/`mt8196` MM/display), `rockchip-iommu.c` (`rk3568`/`rk3588`), `intel/` (VT-d), `amd/`.
- **DeviceTree & Bindings (Target ARM64 Platforms)**:
  - GPU & Display bindings: `Documentation/devicetree/bindings/gpu/` (`arm,mali-valhall-csf.yaml`, `arm,mali-bifrost.yaml`) and `Documentation/devicetree/bindings/display/{msm,mediatek,rockchip}/`.
  - SoC & board DTs under `arch/arm64/boot/dts/`:
    - **Qualcomm**: `qcom/sc7180*.dts*` (Trogdor), `qcom/x1e80100*.dts*`, `qcom/x1p42100*.dts*`, `qcom/x1-*.dtsi`
    - **MediaTek**: `mediatek/mt8186*.dts*` (Corsola), `mediatek/mt8196*.dts*` (Rauru)
    - **Rockchip**: `rockchip/rk3568*.dts*` (`rk356x*.dtsi`), `rockchip/rk3588*.dts*` (`rk3588s*.dtsi`)

## Downstream Kernels & Access Tips

- **Downstream kernels on this device:** For Android Kleaf (`~/android/android*`) or ChromiumOS (`~/chromiumos/src/third_party/kernel/`) vendor/backport trees, use `local-checkout-android` or `local-checkout-chromeos` instead.
- **Access troubleshooting:** If reading `~/projects/linux` from another workspace prompts or fails, ask the user to grant `read_file(~/projects/linux)` (with `~` expanded to the literal home path) in `/permissions`.
