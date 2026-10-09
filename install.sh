#!/usr/bin/env bash
# ============================================================
#  typst-kit 安装脚本
#
#  把仓库里的 typst 笔记工具链部署到本机标准位置：
#    bin/typ                → ~/.local/bin/typ
#    lib/mathnote.typ       → ~/.config/typ/lib/mathnote.typ
#    templates/*            → ~/.config/typ/templates/
#    typst-package/...      → ~/.local/share/typst/packages/local/mathnote/0.1.0/
#    notes/*                → ~/notes/typst/
#    nvim/typst.lua         → ~/.config/nvim/lua/snippets/typst.lua
#
#  默认用**软链**部署：以后 git pull 就全局生效。
#  加 --copy 改成拷贝（部署后与仓库解耦，更新要重跑本脚本）。
#  加 --dry-run 只看会做什么，不落盘。
#
#  兼容的环境变量（与 bin/typ 脚本同名，两边可联动覆盖）：
#    TYP_BIN_DIR  TYP_LIB_DIR  TYP_TEMPLATE_DIR  TYP_PACKAGE_DIR
#    TYP_CHEATSHEET  TYP_MANUAL  TYP_SNIPPETS
# ============================================================
set -euo pipefail

# ── 定位仓库根（本脚本所在目录，穿透软链）────────────────
_realpath() {
  # GNU readlink -f；BSD/macOS 无 -f 时用 python3 兜底
  readlink -f "$1" 2>/dev/null || python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
}
REPO="$(dirname "$(_realpath "${BASH_SOURCE[0]}")")"

# ── 目标位置 ────────────────────────────────────────────
BIN_PATH="${TYP_BIN_DIR:-$HOME/.local/bin}/typ"
LIB_PATH="${TYP_LIB_DIR:-$HOME/.config/typ/lib}/mathnote.typ"
TPL_DIR="${TYP_TEMPLATE_DIR:-$HOME/.config/typ/templates}"
PKG_DIR="${TYP_PACKAGE_DIR:-$HOME/.local/share/typst/packages/local/mathnote/0.1.0}"
NOTES_DIR="${TYP_NOTES_DIR:-$HOME/notes/typst}"
CHEATSHEET_PATH="${TYP_CHEATSHEET:-$NOTES_DIR/00-cheatsheet.typ}"
MANUAL_PATH="${TYP_MANUAL:-$NOTES_DIR/typst-manual.typ}"
SNIPPET_PATH="${TYP_SNIPPETS:-$HOME/.config/nvim/lua/snippets/typst.lua}"

# ── 参数 ────────────────────────────────────────────────
MODE="link"          # link | copy
DRY_RUN=0
BACKUP=1
SKIP_NOTES=0
SKIP_NVIM=0

usage() {
  cat <<'EOF'
用法：bash install.sh [选项]

选项
  --link           软链部署（默认），git pull 后全局立即生效
  --copy           拷贝部署，装完与仓库解耦（更新需重跑本脚本）
  --dry-run        只打印将要执行的动作，不修改任何文件
  --no-backup      不备份被覆盖的已有文件（默认备份为 <文件名>.pre-typst-kit）
  --skip-notes     不部署 ~/notes/typst/（速查表、语法手册）
  --skip-nvim      不部署 nvim 片段（~/.config/nvim/lua/snippets/typst.lua）
  -h, --help       显示这份帮助

部署后
  typ -h                 查看工具用法
  typ init               新建一篇笔记
  typ cheatsheet         编译并打开 typst 速查表
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link)      MODE="link" ;;
    --copy)      MODE="copy" ;;
    --dry-run)   DRY_RUN=1 ;;
    --no-backup) BACKUP=0 ;;
    --skip-notes) SKIP_NOTES=1 ;;
    --skip-nvim)  SKIP_NVIM=1 ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "未知选项：$1（--help 看用法）" >&2; exit 2 ;;
  esac
  shift
done

# ── 输出小工具 ──────────────────────────────────────────
c_ok()   { printf '\033[32m%s\033[0m\n' "$*"; }
c_dim()  { printf '\033[2m%s\033[0m\n' "$*"; }
c_warn() { printf '\033[33m%s\033[0m\n' "$*"; }
err()    { printf '\033[31minstall: %s\033[0m\n' "$*" >&2; }
run()    { if [[ $DRY_RUN -eq 1 ]]; then c_dim "  [dry-run] $*"; else "$@"; fi; }

installed=0
skipped=0

# install_one <源文件> <目标路径>
install_one() {
  local src="$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    err "仓库里找不到 $src，跳过"
    return 0
  fi

  # 已经就位（软链指回仓库同一文件，或内容相同的拷贝）→ 什么都不做
  if [[ -L "$dst" ]] && [[ "$(_realpath "$dst")" == "$(_realpath "$src")" ]]; then
    c_dim "  已是本仓库的软链，跳过：$dst"
    skipped=$((skipped + 1))
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ $BACKUP -eq 1 ]]; then
      local bak="$dst.pre-typst-kit"
      if [[ -e "$bak" || -L "$bak" ]]; then
        c_dim "  先前备份仍在，不覆盖：$bak"
      else
        run cp -a "$dst" "$bak"
        c_dim "  已备份原文件 → $bak"
      fi
    else
      c_warn "  将覆盖已存在的 $dst（--no-backup 未备份）"
    fi
  fi

  run mkdir -p "$(dirname "$dst")"
  if [[ "$MODE" == "link" ]]; then
    run ln -sfn "$src" "$dst"
    c_ok "  软链 $dst → $src"
  else
    run cp -f "$src" "$dst"
    c_ok "  拷贝 $dst"
  fi
  installed=$((installed + 1))
}

echo "typst-kit 安装"
echo "  仓库：$REPO"
echo "  模式：$MODE$([[ $DRY_RUN -eq 1 ]] && echo "（dry-run，不落盘）")"
echo

# ── 1. 命令行工具 ───────────────────────────────────────
echo "· 命令行工具"
install_one "$REPO/bin/typ" "$BIN_PATH"
if [[ $DRY_RUN -eq 0 && -f "$BIN_PATH" ]]; then run chmod +x "$BIN_PATH"; fi

# ── 2. 排版库 ───────────────────────────────────────────
echo "· 排版库"
install_one "$REPO/lib/mathnote.typ" "$LIB_PATH"

# ── 3. 模板 ─────────────────────────────────────────────
echo "· 模板（note / homework / standalone / sample + 生成脚本）"
for f in note.typ homework.typ standalone.typ sample.typ gen-standalone.sh; do
  install_one "$REPO/templates/$f" "$TPL_DIR/$f"
done

# ── 4. typst 本地包 @local/mathnote:0.1.0 ───────────────
echo "· typst 本地包 @local/mathnote:0.1.0"
install_one "$REPO/typst-package/local/mathnote/0.1.0/typst.toml" "$PKG_DIR/typst.toml"
# 包入口 lib.typ 指向排版库本体，保证「改一处、处处生效」
if [[ "$MODE" == "link" ]]; then
  if [[ -L "$PKG_DIR/lib.typ" ]] && [[ "$(_realpath "$PKG_DIR/lib.typ")" == "$(_realpath "$LIB_PATH")" ]]; then
    c_dim "  已是排版库的软链，跳过：$PKG_DIR/lib.typ"
    skipped=$((skipped + 1))
  else
    if [[ -e "$PKG_DIR/lib.typ" || -L "$PKG_DIR/lib.typ" ]]; then
      if [[ $BACKUP -eq 1 && ! -e "$PKG_DIR/lib.typ.pre-typst-kit" ]]; then
        run cp -a "$PKG_DIR/lib.typ" "$PKG_DIR/lib.typ.pre-typst-kit"
      fi
    fi
    run mkdir -p "$PKG_DIR"
    run ln -sfn "$LIB_PATH" "$PKG_DIR/lib.typ"
    c_ok "  软链 $PKG_DIR/lib.typ → $LIB_PATH"
    installed=$((installed + 1))
  fi
else
  install_one "$REPO/lib/mathnote.typ" "$PKG_DIR/lib.typ"
fi

# ── 5. 速查表 / 语法手册 ────────────────────────────────
if [[ $SKIP_NOTES -eq 1 ]]; then
  c_dim "· 速查表 / 语法手册（--skip-notes，跳过）"
else
  echo "· 速查表 / 语法手册"
  install_one "$REPO/notes/00-cheatsheet.typ" "$CHEATSHEET_PATH"
  install_one "$REPO/notes/typst-manual.typ" "$MANUAL_PATH"
fi

# ── 6. nvim 片段 ────────────────────────────────────────
if [[ $SKIP_NVIM -eq 1 ]]; then
  c_dim "· nvim 片段（--skip-nvim，跳过）"
else
  echo "· nvim 片段"
  install_one "$REPO/nvim/typst.lua" "$SNIPPET_PATH"
fi

# ── 收尾检查 ────────────────────────────────────────────
echo
if [[ $DRY_RUN -eq 1 ]]; then
  c_warn "dry-run 结束，未修改任何文件。"
  exit 0
fi

c_ok "✓ 完成：安装 $installed 项，跳过 $skipped 项"

if ! command -v typst >/dev/null 2>&1; then
  c_warn "⚠ 没找到 typst 可执行文件，请先装它（Arch: sudo pacman -S typst；其它: cargo install typst-cli）"
fi
if ! command -v python3 >/dev/null 2>&1; then
  c_warn "⚠ 没找到 python3，typ 是 Python 脚本，需要它"
fi
if ! command -v nvim >/dev/null 2>&1; then
  c_dim "· 没找到 nvim：typ init / typ snippets 不会自动打开编辑器（其余功能正常）"
fi
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) c_warn "⚠ ~/.local/bin 不在 PATH 里，请把它加进 shell 配置（如 fish: fish_add_path ~/.local/bin）" ;;
esac

echo
c_dim "试试：typ -h    然后 typ init 新建一篇笔记"
