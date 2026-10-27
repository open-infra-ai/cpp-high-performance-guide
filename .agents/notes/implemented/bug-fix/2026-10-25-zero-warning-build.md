# Agent Note: debug 构建零警告（自建代码修复 + 第三方 SYSTEM 隔离）

Status: implemented

## Problem

debug 全量构建存在 16 个编译警告：12 个 `-Wfloat-conversion` 来自
`branch_prediction.cpp`（累计和变量 `t` 声明为 `double`，内核返回
`long long`，赋值/传参/比较三处各隐式往返转换），4 个
`-Wconversion` / `-Wsign-compare` 来自 pinned rapidcheck 头文件。警告噪音
会淹没未来真正的问题信号，与「可验证的教学仓」定位不符。

## Decision

两层修复：自建代码的 `t` 改为 `long long`（对 ≤2^53 的求和值语义不变，
且消除了 double 往返的精度隐患）；rapidcheck 的 include 目录经
`INTERFACE_SYSTEM_INCLUDE_DIRECTORIES` 标记为 system——该属性是对
`INTERFACE_INCLUDE_DIRECTORIES` 中既有条目的标记（同 genex 字符串交集），
不是独立 include 来源；清除原属性会导致消费方找不到头文件。googletest
即以此机制获得 `-isystem`。

## Alternatives considered

- **只修自建代码、容忍第三方警告** — 4 个噪音持续存在，且与 gtest 的
  isystem 待遇不一致。
- **升级 cmake_minimum_required 到 3.25 用 `FetchContent_Declare(SYSTEM)`**
  — 语法最简洁；但抬高用户工具链门槛，仓声明支持 3.20。
- **把 rapidcheck 属性值引号包裹后用 set_target_properties** — 列表被压成
  单个坏路径；且 set_target_properties 无法赋列表属性（实测报参数数错误）。

## Consequences

- **收益**：debug 全量构建 0 警告（自建与第三方合计）；119/119 测试通过。
- **代价**：rapidcheck 升级换 pin 后需确认新声明仍是普通 include 属性
  （标记逻辑取的是当时的属性值，增删目录自动跟随）。

## Verification

`rm -rf build/debug && cmake --preset=debug && cmake --build --preset debug`
输出 `warning:` 计数为 0；`ctest --preset=debug` 119/119；build.ninja 中
rapidcheck-src/include 以 `-isystem` 形式出现。
