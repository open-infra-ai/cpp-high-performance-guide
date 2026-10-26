# Agent Note: clang 构建移除 GCC 专属 -fno-if-conversion

Status: implemented

## Problem

08-cpu-microarch 的模块 CMake 在 `HPC_IS_CLANG` 分支给
`microarch_kernels.cpp` 传 `-fno-if-conversion`。该参数是 GCC 专属：clang
直接报 `unknown argument`。tsan 预设强制使用 clang 编译，因此 tsan 构建失败，
CI 自 2026-08-06 起为红灯（该模块与 09-matrix-multiply 同批合入，仓库随后
进入休眠，红灯静默两个多月）。

## Decision

从 clang 分支移除 `-fno-if-conversion`（clang 无公开的 if-conversion 开关，
sum_ternary 的 cmov 演示依赖 clang 默认行为，已在源码与 CMake 注释说明）；
GCC 分支的 `-fno-tree-vectorize;-fno-if-conversion` 保持不变——禁用
if-conversion 以保住 sum_branched 的真实分支正是 GCC 侧演示的核心。

## Alternatives considered

- **给 clang 找等价参数** — if-conversion 在 clang 后端进行，无用户开关，
  无从等价。
- **连 GCC 分支一起删** — sum_branched 会被 GCC 降级成 cmov，分支预测
  演示（本模块的存在理由）失效。

## Consequences

- **收益**：tsan 构建恢复；clang 构建下 08 模块行为与注释一致。
- **代价**：clang 构建中 sum_branched「保持真实分支」依赖 clang 默认不做
  激进 if-conversion 的事实，属于不可显式保证的行为边界。

## Verification

tsan 全套（clang 18.1.3，与 CI 同版本）本地 119/119 通过；CI 五个 job 全绿。
