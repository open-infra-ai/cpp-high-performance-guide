# cpp-high-performance-guide · Agent 约定

仓库定位：`open-infra-ai` 组织第七个技术仓，CPU 侧 C++20 高性能工程教学
（状态 **stable**，作品完成，只修正确性 bug 与文档）；权威状态注册表见
[open-infra-ai/open-infra-ai](https://github.com/open-infra-ai/open-infra-ai)。

## 重要改动必须留笔记

本仓使用 [write-notes-like-deepseek](.agents/skills/write-notes-like-deepseek/SKILL.md)
决策笔记体系（方法提炼自 DeepSeek Harness 工程实践）。

1. 非平凡改动（改了行为、架构、跨文件契约、流程与工具链、测试策略、落盘/网络/配置格式）前，遵循
   `.agents/skills/write-notes-like-deepseek/SKILL.md` 写或更新笔记；机械性小改
   （样式、格式化、打标、不改行为的补丁）直接提交。
2. 写之前先检索 `.agents/notes/` 里的同主题旧笔记：有归属就地更新；新想法先放
   `proposed/`，落地随同代码改动转 `implemented/`；新方案彻底取代旧决策时，
   同批归档旧篇并标明被谁取代。
3. 被放弃的方案先写它最强的理由，再解释为什么不用。
4. 提交前跑 `npm run verify-notes`，红了先修再交。

笔记路径即状态：`.agents/notes/{proposed,implemented,rejected,archived}/{feature,bug-fix,simplification,architecture,process,testing}/yyyy-mm-dd-topic.md`。

## 写文档

- 写/改 agent 可见文档（本文件、skill、指针文档）：先读
  `.agents/skills/writing-for-agents/SKILL.md`
- 写/改用户可见技术文档（README、docs/）：遵循
  `.agents/skills/documentation-writer/SKILL.md`（Diátaxis 四象限）

## Project position

This repository is in **stable maintenance** (feature work paused since 2026-08; correctness fixes and documentation only). The canonical header-only library lives in `include/hpc/` (consumed via the `hpc_headers` INTERFACE target); example and demo code lives in `examples/` and depends only on the canonical library, never the reverse. Prefer normalization, defect fixing, and removal of stale or low-signal surfaces over accumulating redundant surfaces.

## C++ Standards and Style

- **Target**: C++20 (required, `CMAKE_CXX_STANDARD_REQUIRED ON`)
- **Style**: enforced via `.clang-format` (Google style, 100 chars)
- **Memory safety**: prefer RAII, smart pointers, avoid raw `new/delete`
- **Performance**: always measure with benchmarks before claiming improvement
- **Concurrency**: use `std::atomic` with explicit memory ordering
- **Header-only design**: all library code lives in `include/hpc/` (consumed via the `hpc_headers` INTERFACE target). Platform-specific code is hidden behind preprocessor conditionals within headers.

## Repository layout

```text
cpp-high-performance-guide/
├── CMakeLists.txt
├── CMakePresets.json
├── cmake/
├── examples/
├── tests/
├── benchmarks/
├── tools/
├── scripts/
├── docs/                  # VitePress site (Chinese only)
├── .githooks/             # Project-managed Git hooks
└── .github/
```

## Standard commands

```bash
# Build and test
cmake --preset=debug && cmake --build build/debug && ctest --preset=debug
cmake --preset=release && cmake --build build/release && ctest --preset=release

# Sanitizers
cmake --preset=asan && cmake --build build/asan && ctest --preset=asan
cmake --preset=tsan && cmake --build build/tsan && ctest --preset=tsan
cmake --preset=ubsan && cmake --build build/ubsan && ctest --preset=ubsan

# Benchmarks
cmake --preset=release && cmake --build build/release
./build/release/examples/<module-dir>/<benchmark_name> --benchmark_time_unit=us
# 例: ./build/release/examples/02-memory-cache/aos_vs_soa_bench --benchmark_time_unit=us

# Utilities
./scripts/format.sh
./scripts/setup-hooks.sh
npm run verify-notes
```

## Engineering rules

- Prefer **deleting or archiving stale content** instead of preserving redundant surfaces.
- Keep **README** focused on repository entry and onboarding; use the docs site for the richer narrative.
- Treat **GitHub Pages** as a project landing page, not a thin README mirror.
- Documentation is **Chinese only**. Do not reintroduce English documentation surfaces.
- Use **CMake presets** as the default build and test entry points.
- Keep workflows **preset-driven, low-noise, and meaningful**.
- Avoid over-engineering with extra plugins, MCP servers, or automation layers unless they clearly reduce maintenance cost.

## AI tooling policy

- **AGENTS.md**（本文件）：仓库约定唯一事实源；`CLAUDE.md` 是指向它的符号链接。
- **LSP**: prefer `clangd` backed by `compile_commands.json`. The `.clangd` config at the repo root points `CompilationDatabase` to `build/debug`.
- **Review model**: use `/review` before merge or after major cleanup phases.

## Editor integration

The `.vscode/` directory is **gitignored**. Use `.clangd`, `.editorconfig`, and `CMakePresets.json` for machine-readable project conventions.

## Things to avoid reintroducing

- non-blocking CI steps that hide real failures
- per-example shim headers that only re-export a canonical `include/hpc/` header
- wrapper scripts that duplicate `cmake --preset` commands
- English documentation surfaces or bilingual parity machinery
