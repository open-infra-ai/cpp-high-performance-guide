# Agent Note: gemm_test 的 OpenMP 链接改为条件式

Status: implemented

## Problem

`tests/unit/gemm/CMakeLists.txt` 无条件链接 `OpenMP::OpenMP_CXX`，而根 CMake
的设计是「OpenMP 缺失时禁用相关示例、优雅降级」——无 OpenMP 的环境（如精简
容器）在配置阶段直接失败。另外 `hpc_set_compiler_options(gemm_test
ENABLE_OPENMP)` 传了该函数不认识的实参（`ENABLE_OPENMP` 属于
`_hpc_configure_target` 的参数表），是复制粘贴残留。

## Decision

OpenMP 链接统一守卫在 `if(OpenMP_CXX_FOUND)`（与 `_hpc_configure_target`
的 `ARG_ENABLE_OPENMP AND OpenMP_CXX_FOUND` 同模式）；移除无效实参。测试
本体不跳过：`hpc::gemm::parallel` 无 OpenMP 时回退为 simd（头文件既有设计），
四个阶段的正确性验证在任何环境都保留。

## Alternatives considered

- **无 OpenMP 时整个 gemm_test 跳过** — 损失 naive/tiled/simd 阶段的覆盖，
  与「回退而非禁用」的头文件设计相悖。
- **保持现状，只在 CI 保证 OpenMP 存在** — 降级承诺形同虚设，最小环境无法
  配置，正是被暴露的缺陷本身。

## Consequences

- **收益**：无 OpenMP 环境可配置、构建并通过全部测试；OpenMP 环境行为不变。
- **代价**：无 OpenMP 时 parallel 阶段实际验证的是 simd 回退路径（GEMM 数值
  正确性仍被验证，OpenMP 调度本身不覆盖）。

## Verification

`-DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=TRUE` 关闭示例与基准后全套测试本地
通过；常规路径（OpenMP 存在）的 tsan 构建已包含 gemm_test 且全绿。
