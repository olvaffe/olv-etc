---
name: local-checkout-vulkan
description: >-
  Queries the local Khronos Vulkan specification and XML registry at ~/projects/Vulkan-Docs/
  for Vulkan driver implementation and application development (command/struct semantics,
  pNext chains, VUIDs, extensions, features, limits, formats, synchronization, and SPIR-V rules).
  Use whenever checking authoritative Vulkan API behavior, validation rules, or driver requirements.
---

# Vulkan Spec Reference for App & Driver Development (`~/projects/Vulkan-Docs/`)

`~/projects/Vulkan-Docs` is used strictly as a **read-only, unbuilt reference** (expand `~` to the user's home directory when calling `read_file`).

## Critical Rules for This Unbuilt Checkout

- **Ignore all build/authoring machinery:** Never run or inspect `Makefile`, `makeSpec`, `makeExt`, `scripts/`, `config/`, `antora/`, `katex/`, `build_tests/`, `BUILD.adoc`, `CONTRIBUTING.adoc`, or `ChangeLog*.adoc`.
- **`{generated}/` does NOT exist on disk:** Raw `.adoc` files contain `include::{generated}/api/...` (C declarations) and `include::{generated}/validity/...` (implicit VUIDs). Do not look for `{generated}` files—read C layouts, prototypes, and implicit validity attributes directly from `~/projects/Vulkan-Docs/xml/vk.xml`.
- **Skip `appendices/VK_*.adoc` for extension APIs:** In an unbuilt tree, `appendices/VK_<EXT>.adoc` only has contributor metadata, a short blurb, and an unbuilt `{generated}/interfaces/` include. Use `xml/vk.xml` + `chapters/` + `proposals/` instead (see recipe below).
- **Ignore Vulkan SC blocks:** Skip `ifdef::VKSC_VERSION_1_0[]` sections and `appendices/sc_static/` unless explicitly asked about Vulkan SC.

## Fast 1-Step Lookup Recipes

### 1. Command, Struct, Handle, or Enum Semantics (`refpage` jump)
Avoid noisy full-text searches (symbols like `vkCmdDraw` appear thousands of times via `flink:` cross-references). Jump straight to the single canonical definition block:
```bash
git -C ~/projects/Vulkan-Docs grep -n "refpage='<Symbol>'" -- chapters/
```
Then `read_file` around that line in `chapters/` for parameter semantics, behavioral prose, and explicit `.Valid Usage` VUIDs.

### 2. C Signatures, `pNext` Chains, Formats, Sync Matrix & SPIR-V Gates (`xml/vk.xml`)
Never `read_file` `xml/vk.xml` (~3.3 MB) linearly; query it with a short Python `xml.etree.ElementTree` one-liner (`ET.parse(Path('~/projects/Vulkan-Docs/xml/vk.xml').expanduser())`). Key top-level sections:
- `<types>` — Exact C struct fields, `values="VK_STRUCTURE_TYPE_..."`, `structextends="..."` (all valid `pNext` structs), `returnedonly`, `optional`, `len`, `noautovalidity`.
- `<commands>` — Prototypes, `successcodes`/`errorcodes`, `externsync`, plus driver/command-buffer constraints (`queues`, `renderpass="inside|outside|both"`, `cmdbufferlevel`, `tasks`).
- `<feature>` & `<extensions>` — Core 1.0–1.4 promotions, `type="instance|device"`, `depends` expressions, `promotedto`/`deprecatedby`, enum extension numbers/offsets, and required types/commands/features.
- `<formats>` — Per-`VkFormat` `class`, `blockSize`, `texelsPerBlock`, `blockExtent`, `compressed`, `<component>`, `<plane>` (multi-planar YCbCr), and `<spirvimageformat>`.
- `<sync>` — Machine-readable `<syncstage>`, `<syncaccess>` (valid stage masks per access flag!), and `<syncpipeline>`.
- `<spirvcapabilities>` & `<spirvextensions>` — Exact Vulkan version, feature struct bit, extension, or property enabling each SPIR-V capability/extension.
- `<videocodecs>` (plus `~/projects/Vulkan-Docs/xml/video.xml` for codec Std headers).

### 3. Looking Up an Extension (`VK_KHR_*` / `VK_EXT_*` / Vendor)
1. **Surface & dependencies:** Query `<extension name="VK_<EXT>">` in `xml/vk.xml` for its feature/property structs, commands, enums, `depends`, and core promotion status.
2. **Design intent & usage examples:** Check if `~/projects/Vulkan-Docs/proposals/VK_<EXT>.adoc` exists and read it.
3. **Normative behavior & VUIDs:** Run `git -C ~/projects/Vulkan-Docs grep -n "VK_<EXT>" -- chapters/` and read the gated sections.

### 4. Looking Up a Validation Layer VUID (`VUID-...`)
- **Numeric VUIDs (`VUID-<Parent>-<param>-<5digits>`):** Explicit rules written in AsciiDoc:
  ```bash
  git -C ~/projects/Vulkan-Docs grep -n "VUID-..." -- chapters/
  ```
  *(If the match is a shared fragment in `chapters/commonvalidity/*.adoc`, also grep that fragment's filename in `chapters/` to see which commands include it and under what `ifdef::` guards.)*
- **Implicit VUIDs (ending in `-parameter`, `-sType`, `-sType-unique`, `-pNext`, `-parent`, `-commonparent`, `-arraylength`, `-mustBeNull`):** Not present in `.adoc` files—they are auto-generated from `optional`, `len`, `structextends`, and `values` attributes in `xml/vk.xml`.

### 5. Feature Bits & Physical Device Limits
- **Feature bit (`VkPhysicalDevice*Features*`):** `git -C ~/projects/Vulkan-Docs grep -n "features-<fieldName>" -- chapters/features.adoc` (also check `[[features-extension-aliases-table]]` near the top of `features.adoc` for promoted feature aliases).
- **Device limit (`VkPhysicalDeviceLimits` / `*Properties*`):** `git -C ~/projects/Vulkan-Docs grep -n "limits-<fieldName>" -- chapters/limits.adoc`.

## Chapter & Appendix Map (Normative Content Only)

- **Execution, Queues & Sync**: `devsandqueues.adoc`, `cmdbuffers.adoc`, `synchronization.adoc`, `device_generated_commands/`
- **Memory, Resources & Descriptors**: `memory.adoc`, `sparsemem.adoc`, `resources.adoc` (buffers, images, views), `descriptorsets.adoc`, `descriptorbuffers.adoc`, `descriptorheaps.adoc`, `samplers.adoc`, `copies.adoc`, `clears.adoc`
- **Shaders, SPIR-V & Pipelines**: `shaders.adoc`, `interfaces.adoc`, `pipelines.adoc`, `appendices/spirvenv.adoc` (SPIR-V validation & env rules), `appendices/memorymodel.adoc`
- **Graphics & Compute Stages**: `dispatch.adoc`, `drawing.adoc`, `fxvertex.adoc`, `tessellation.adoc`, `geometry.adoc`, `VK_NV_mesh_shader/mesh.adoc`, `vertexpostproc.adoc`, `primsrast.adoc`, `fragops.adoc`, `renderpass.adoc` (includes dynamic rendering), `framebuffer.adoc`, `textures.adoc`
- **Ray Tracing, Video & ML/Compute**: `accelstructures.adoc`, `raytracing.adoc`, `raytraversal.adoc`, `VK_KHR_opacity_micromap/`, `videocoding.adoc`, `video/*.adoc`, `executiongraphs.adoc`, `VK_ARM_tensors/`, `VK_ARM_data_graph/`
- **Formats, Capabilities, WSI & Queries**: `formats.adoc`, `appendices/compressedtex.adoc`, `features.adoc`, `limits.adoc`, `capabilities.adoc`, `VK_KHR_surface/wsi.adoc`, `queries.adoc`, `debugging.adoc`

## Reading Raw AsciiDoc Accurately

- **Always inspect surrounding `ifdef::...[]` / `ifndef::...[]` guards!** Vulkan state requirements and VUIDs regularly change when extensions or core versions (e.g., `VK_KHR_dynamic_rendering`, `VK_EXT_shader_object`, `VK_KHR_maintenance1`..`8`, `VK_EXT_descriptor_buffer`) are active. `,` inside `ifdef::A,B[]` means **OR** (`A` or `B`); `+` inside `ifdef::A+B[]` means **AND** (`A` and `B`).
- **Markup shorthand:** `flink:`/`fname:` = command, `slink:`/`sname:` = struct/handle, `elink:`/`ename:` = enum/bit, `pname:` = param/field, `apiext:` = extension, `must:`/`should:`/`may:`/`can:`/`cannot:` = normative keywords.
- **Access troubleshooting:** If reading `~/projects/Vulkan-Docs` from another workspace prompts or fails, ask the user to grant `read_file(~/projects/Vulkan-Docs)` (with `~` expanded to the literal home path) in `/permissions`.
