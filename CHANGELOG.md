# Changelog

本仓维护轻量 changelog：记录发布级里程碑与维护批次，不做逐日流水。历史条目
不改写；当时事实的叙述保持原文。

## [Unreleased]

### Fixed

- 08-cpu-microarch 在 clang 构建下不再传递 GCC 专属 `-fno-if-conversion`：
  tsan 预设强制使用 clang，此前因该参数构建失败，CI 自 2026-08-06 起为红灯。
- `sum_ternary` 的 GCC `optimize` 属性改由 `MICROARCH_ENABLE_IF_CONVERSION`
  宏承载，消除 clang-format 18（CI）与 21（本地）对 `#if` 包裹声明的
  返回类型折行分歧。
- tsan 测试预设补 `ignore_noninstrumented_modules=1`，屏蔽 libomp（未插桩
  OpenMP 运行时）的已知误报；GemmTest.SmallSizes / KnownValues 恢复通过。
- `tests/unit/gemm` 的 OpenMP 链接改为 `if(OpenMP_CXX_FOUND)` 条件式，与根
  CMake「无 OpenMP 优雅降级」的设计一致（`hpc::gemm::parallel` 无 OpenMP 时
  回退 simd，测试照常构建）；移除 `hpc_set_compiler_options` 的无效
  `ENABLE_OPENMP` 实参。

### Changed

- 徽章、克隆地址、文档站链接、OG 分享卡与 Pages 部署守卫由旧个人账号
  （LessUp）统一为 `open-infra-ai` 组织；文档站恢复自动部署。
- README 登记 **stable** 状态行；CLAUDE.md 的技术约定并入 AGENTS.md
  （CLAUDE.md 改为符号链接）。
- 接入 `.agents/notes` 决策笔记体系与 `verify-notes` CI 门禁，与其他技术仓
  治理口径一致。
