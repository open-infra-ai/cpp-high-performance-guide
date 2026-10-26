# Agent Note: CI 增加 release 预设门禁

Status: implemented

## Problem

CI 只有格式检查、GCC debug 与 asan/tsan/ubsan；`release` 预设虽已定义并有对应
test preset，但从未在 CI 执行。`-O3 -DNDEBUG` 下才会暴露的问题（断言代码被
裁掉、优化触发告警、模板实例化差异）只能在本地手工发现。毕业文档将
「release 预设纳入 CI」列为该仓首个补强项。

## Decision

在 `.github/workflows/ci.yml` 增加 `linux-release-gcc` job，与 debug job 同构：
gcc-12、ninja、libomp，复用 `_deps` 与 ccache 缓存，执行
`cmake --preset=release`、`cmake --build --preset release`、
`ctest --preset=release`。test preset 已排除 `benchmark` label，因此 CI 只跑
正确性测试，不把基准耗时与噪声引入门禁；超时上限 45 分钟。

## Alternatives considered

- **release 只构建不测试**：编译覆盖成本更低，但会漏掉断言裁剪与优化相关的
  运行时差异，且与 debug job 的职责无法对齐。
- **关闭 `HPC_BUILD_BENCHMARKS` 省时间**：会失去 Google Benchmark 在 release
  下的编译覆盖；当前选择保留编译、只排除运行。
- **同时在 CI 跑 benchmark 收集数字**：runner 噪声大、结果不可复现，不能作为
  性能证据，故不做。
- **GCC + Clang release 矩阵**：跨编译器覆盖更强，但本次只关闭“release 无
  CI”这一缺口；跨编译器矩阵仍留在毕业文档的待办中。

## Verification

本机 `cmake --preset=release` + `cmake --build --preset release` 成功；
`ctest --preset=release` 119/119 通过（1.92 s，benchmark label 已排除）。
冷配置在本机 WSL 上耗时较长（依赖拉取），CI 侧依赖 `_deps` 缓存。
workflow 变更随推送由远端 CI 实际执行验证。

## Consequences

默认分支每次推送多一个 release job，CI 时长增加；换来 `-O3` 下的构建与测试
覆盖。仍未覆盖 ARM、MSVC 与 benchmark 执行，这些不因本改动而可宣称完成。
