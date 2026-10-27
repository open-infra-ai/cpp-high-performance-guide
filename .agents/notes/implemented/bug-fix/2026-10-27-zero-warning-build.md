# Agent Note: debug 构建零警告（第三方头 SYSTEM 隔离）

Status: implemented

## Problem

debug 全量构建存在 4 个编译警告，全部来自 pinned rapidcheck 头文件
（`Numeric.hpp` 的 `-Wconversion`、`Capture.h` 的 `-Wsign-compare`）。
自建代码的 12 个 `-Wfloat-conversion` 已由维护者在 `3c0c159` 修复
（`branch_prediction.cpp` 累计和变量改 `long long`）。第三方警告噪音会
淹没未来真正的问题信号，与「可验证的教学仓」定位不符；googletest 同为
FetchContent 依赖却享受 `-isystem` 待遇，口径不一致。

## Decision

把 rapidcheck 已声明的 include 目录标记为 system：
`get_target_property` 读取 `INTERFACE_INCLUDE_DIRECTORIES` 后原值写入
`INTERFACE_SYSTEM_INCLUDE_DIRECTORIES`。关键语义：后者不是独立的 include
来源，而是对前者中同路径条目的标记（交集生效）——清除原属性会导致消费方
找不到头文件（实测三次失败后确认）。googletest 即以此机制获得 `-isystem`。

## Alternatives considered

- **容忍第三方警告** — 4 个噪音持续存在，且与 gtest 待遇不一致。
- **升级 cmake_minimum_required 到 3.25 用 `FetchContent_Declare(SYSTEM)`**
  — 语法最简；但抬高用户工具链门槛，仓声明支持 3.20。
- **清空原属性、只留 SYSTEM 属性** — 实测消费方丢失 include，
  `rapidcheck.h` 找不到。

## Consequences

- **收益**：debug 全量构建 0 警告（自建与第三方合计）；119/119 测试通过；
  rapidcheck 换 pin 后标记自动跟随新声明的属性值。
- **代价**：多一段 CMake 逻辑；若未来升级到 3.25 可简化为一行
  `SYSTEM` 关键字。

## Verification

`rm -rf build/debug && cmake --preset=debug && cmake --build --preset debug`
输出 `warning:` 计数为 0；`ctest --preset=debug` 119/119；build.ninja 中
rapidcheck-src/include 以 `-isystem` 形式出现。
