#!/usr/bin/env bash
# 由 lib/mathnote.typ 生成自包含单文件模板 templates/standalone.typ
# 改完库之后跑一次这个，standalone 就同步了（别手改 standalone.typ）
set -euo pipefail

# 按脚本自身的**真实**路径推导（readlink -f 会穿透软链），
# 于是「在仓库里跑」和「经 install.sh 软链后在 ~/.config/typ 里跑」写的是同一份 standalone.typ
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
HERE="$(dirname "$SELF")"
LIB="$HERE/../lib/mathnote.typ"
OUT="$HERE/standalone.typ"

[[ -f "$LIB" ]] || { echo "找不到排版库 $LIB" >&2; exit 1; }

{
  cat <<'HDR'
// ============================================================
//  数学笔记 · 自包含模板（`typ init -s` 用这个）
//  ⚠ 本文件由 gen-standalone.sh 从 mathnote.typ 自动生成，不要手改
//    改库之后跑：bash ~/.config/typ/templates/gen-standalone.sh
//  · 排版定义整段都在这个文件里，不 import 本地包 —— 单文件自包含、能直接发给别人
//  · 标题由 `typ init` 用文件名自动填好（下面的 __TITLE__）
//  · 预览：<Space>tp    速查表：~/notes/typst/00-cheatsheet.typ
//  · 想「改一处、所有笔记同步」：用默认模板（引用 @local/mathnote:0.1.0）
// ============================================================
HDR
  tail -n +13 "$LIB"
  printf '\n// ════════════ 正文从这里开始 ════════════\n'
  printf '#show: note.with(title: "__TITLE__")\n'
} > "$OUT"

echo "✓ 已生成 $OUT（$(wc -l < "$OUT") 行）"
