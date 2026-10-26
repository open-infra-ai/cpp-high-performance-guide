# Agent Note: tsan 预设屏蔽 libomp 已知误报

Status: implemented

## Problem

GemmTest.SmallSizes / KnownValues 在 tsan 下失败：ThreadSanitizer 报告的
data race 完全发生在 libomp.so.5（未插桩的 OpenMP 运行时）内部的
pthread_mutex init/lock 上，且测试预设的 `halt_on_error=1` 使第一份报告即
判失败。TSan 输出本身建议 `ignore_noninstrumented_modules=1`。09-matrix-
multiply 的 OpenMP 并行阶段首次让测试在 tsan 下真正进入 OpenMP 运行时，
暴露此问题。

## Decision

tsan 测试预设的 `TSAN_OPTIONS` 追加 `ignore_noninstrumented_modules=1`
（保留 `halt_on_error=1`），并同步更新 profiling 指南与 cmake deep-dive
文档中引用的 preset 值，避免文档与实际行为漂移。

## Alternatives considered

- **按标签把 gemm_test 从 tsan 过滤掉** — 连 GEMM 自身代码的真实数据竞争
  也不再检测，放弃覆盖换取安静。
- **只在 CI workflow 里设环境变量** — 本地 `ctest --preset=tsan` 与 CI 行为
  不一致，preset 的「CI 一致性」承诺失效。

## Consequences

- **收益**：tsan 套件 119/119 通过；本地与 CI 同口径。
- **代价**：libomp 内部的真实问题（若有）不再报告——这是该选项的已知语义，
  对插桩代码（本仓全部源码）的检测不受影响。

## Verification

本地 clang 18.1.3（与 CI 同版本）tsan 全套 119/119 通过；CI 的
Sanitizers (tsan) job 绿。
