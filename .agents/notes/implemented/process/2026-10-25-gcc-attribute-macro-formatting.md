# Agent Note: GCC 属性经宏承载以稳定跨版本格式化

Status: implemented

## Problem

`sum_ternary` 的 GCC `optimize("if-conversion")` 属性需要
`#if defined(__GNUC__) && !defined(__clang__)` 预处理守卫，紧跟函数签名。
clang-format 18（CI 的 apt 版本）与 21（本地新版）对这种「预处理守卫 +
属性 + 签名」的返回类型折行行为相反：18 坚持折行，21 坚持不折。直接格式化
只能满足其中一个版本，Formatting job 必红其一。

## Decision

属性定义收敛为文件顶部的 `MICROARCH_ENABLE_IF_CONVERSION` 宏（GCC 下展开为
属性，clang 下为空），声明前只剩一个普通宏调用行，两个版本的格式化器都
按普通函数签名处理，折行分歧消失。

## Alternatives considered

- **`// clang-format off/on` 包裹声明** — 实测 `on` 标记放在签名前或函数体
  内，都会让某一版格式化器对声明或 `{` 行产生新的分歧，按下葫芦浮起瓢。
- **按 CI 的 18 折行返回类型** — 本地 21 判为违规，开发者本地检查永远红。
- **CI 里钉死 clang-format 版本** — 治标；运行器镜像升级后仍会漂移，且与
  本地默认版本脱节。

## Consequences

- **收益**：18 与 21 双版本格式检查均通过（`CLANG_FORMAT` 环境变量可切换
  版本）；宏名本身把「这一行为什么存在」写进了代码。
- **代价**：多一个宏定义；读者需要跳到文件顶部看展开。

## Verification

18.1.3 与 21.1.8 两个版本的 `./scripts/format.sh --check` 均通过；
g++（属性展开）与 clang++（空宏）`-fsyntax-only` 双通过。
