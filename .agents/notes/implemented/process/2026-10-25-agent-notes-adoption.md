# Agent Note: 接入决策笔记体系

Status: implemented

## Problem

本仓 2026-10-25 以 stable 入册组织状态注册表，成为第七个技术仓，但未接入
其他技术仓统一的 `.agents/notes` 决策笔记体系与 `verify-notes` CI 门禁；
非平凡改动缺少与其他仓一致的决策记录入口，而 2026-08 起的 CI 红灯静默
两个多月无人发现，正说明缺少决策与验证记录的代价。

## Decision

从 trifuse 复制 write-notes-like-deepseek 体系（三个 skill、八个校验脚本、
verify-notes workflow、package.json 脚本入口）；CLAUDE.md 的技术约定并入
AGENTS.md 后改为指向它的符号链接（与工作区根的做法一致，单一事实源）。
本批 2026-10-25 的四项修复作为首批 implemented 种子笔记入库。`.gitignore`
继续排除其他 agent 本地文件，但显式放行 `.agents/notes/`，防止笔记只在本地
通过校验、提交时却被静默遗漏。

## Alternatives considered

- **不接入，保持无笔记状态** — 仓库已 stable、改动频率低；但入册后与其他
  技术仓治理不对称，且红灯静默的教训直接反驳了这个理由。
- **只加 CI 门禁不写种子笔记** — 有门禁无内容；种子笔记同时示范格式与
  检索入口，缺一不可。

## Consequences

- **收益**：与其他技术仓一致的笔记纪律与 CI 门禁；本批历史修复（tsan flag、
  格式化分歧、libomp 误报、OpenMP 条件链接）各有可检索的决策记录。
- **代价**：提交前多一步 `npm run verify-notes`；AGENTS.md/CLAUDE.md 合并后
  只维护单一文件。

## Verification

`npm run verify-notes` 本地通过；`verify-notes.yml` 随本批接入，push master
与 PR 时生效。
