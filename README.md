# typst-kit

一套给 Typst 用的中文数学笔记工具链：一个零依赖的命令行工具 `typ`、一套可复用的排版模板与排版库，外加速查表和 nvim 片段。

在任意一台新设备上克隆本仓库并跑一次 `install.sh`，就能得到和原机器一致的 Typst 写作环境。

## 装什么

| 仓库里的路径 | 部署到 | 作用 |
| --- | --- | --- |
| `bin/typ` | `~/.local/bin/typ` | 命令行工具（Python 3，无第三方依赖） |
| `lib/mathnote.typ` | `~/.config/typ/lib/mathnote.typ` | 排版库本体（环境、编号、标题样式等） |
| `templates/` | `~/.config/typ/templates/`（**整个目录**软链） | 四种模板 + 自包含模板生成脚本 |
| `typst-package/` | `~/.local/share/typst/packages/local/mathnote/0.1.0/` | typst 本地包 `@local/mathnote:0.1.0` |
| `notes/` | `~/notes/typst/` | 速查表、语法手册 |
| `nvim/typst.lua` | `~/.config/nvim/lua/snippets/typst.lua` | nvim 里的数学片段定义 |

## 安装

需要 `typst` 和 `python3`（`typ` 是 Python 脚本，只用标准库）；`nvim` 可选——没有它也能建文件、只是不会自动打开编辑器。

```bash
git clone https://github.com/timetetng/typst-kit.git
cd typst-kit
bash install.sh            # 默认软链部署
```

默认用**软链**：仓库就是唯一真源，以后 `git pull` 立即全局生效。想先看会改哪些文件：

```bash
bash install.sh --dry-run
```

常用选项：

| 选项 | 说明 |
| --- | --- |
| `--copy` | 改成拷贝部署，装完与仓库解耦（更新需重跑本脚本） |
| `--dry-run` | 只打印动作，不修改任何文件 |
| `--no-backup` | 不备份被覆盖的已有文件（默认备份为 `<文件名>.pre-typst-kit`） |
| `--skip-notes` / `--skip-nvim` | 跳过速查表 / 跳过 nvim 片段 |

安装前的文件会就地备份为 `*.pre-typst-kit`，**卸载**就是删掉软链、把备份改回原名。

## 用法

```bash
typ init                   # 新建笔记（引用式模板，排版改一处、所有笔记同步）
typ init -s 报告           # 新建自包含单文件笔记（可直接发给别人）
typ init -t homework 作业1 # 用作业模板
typ init -t sample         # 带示例的模板，学写法用
typ compile                # 编译当前目录的 .typ（多个文件时上下键选）
typ cheatsheet             # 编译并打开 Typst 速查表
typ snippets               # 打开 nvim 片段定义
typ snippets --stats       # 看哪些片段常用、哪些没用过
typ -h                     # 完整帮助
```

命令可以简写：`i` = `init`，`c` = `compile`，`s` = `snippets`。

## 目录结构

```text
typst-kit/
├── bin/typ                       # 命令行工具
├── lib/mathnote.typ              # 排版库（唯一真源）
├── templates/
│   ├── note.typ                  # 引用式空模板（默认）
│   ├── homework.typ              # 作业模板
│   ├── standalone.typ            # 自包含模板，由 gen-standalone.sh 从 lib 生成
│   ├── sample.typ                # 带示例的模板
│   └── gen-standalone.sh         # 重新生成 standalone.typ
├── typst-package/local/mathnote/0.1.0/typst.toml
├── notes/
│   ├── 00-cheatsheet.typ         # 速查表
│   └── typst-manual.typ          # 语法手册
├── nvim/typst.lua                # nvim 片段
└── install.sh
```

## 改已有文件 / 加新模板

link 模式下部署出去的都是指向仓库的软链，**改哪边都是改同一份**，推荐直接在仓库里改（`git diff` / `git add` 顺手）。nvim 保存软链文件不会打断软链（已实测）。

`~/.config/typ/templates/` 连**目录本身**都是软链，所以：

```bash
typ init -t paper          # 还没有 paper.typ？直接建就行
echo '// 新模板' > ~/.config/typ/templates/paper.typ   # 等于写进仓库 templates/paper.typ
cd ~/Projects/typst-kit && git add templates/paper.typ  # 提交后别的设备就能拿到
```

拷贝模式（`--copy`）下没有这层联动，新模板要放进仓库再重跑 `install.sh`。

## 改排版

`lib/mathnote.typ` 是排版库的唯一真源。引用式笔记通过本地包 `@local/mathnote:0.1.0` 使用它，所以改一处、所有笔记同步生效。

`templates/standalone.typ` 是从排版库**自动生成**的自包含副本（给"要把单个文件发给别人"的场合用），改完库记得重新生成：

```bash
bash templates/gen-standalone.sh
```

脚本按自身真实路径推导输入输出，所以无论是从仓库里跑还是从 `~/.config/typ/templates/` 跑（软链安装后是同一份），结果都写回仓库。

## 环境变量

部署位置可用环境变量覆盖（`install.sh` 和 `bin/typ` 同名共用）：

`TYP_BIN_DIR`、`TYP_LIB_DIR`、`TYP_TEMPLATE_DIR`、`TYP_PACKAGE_DIR`、`TYP_CHEATSHEET`、`TYP_MANUAL`、`TYP_SNIPPETS`、`TYP_CACHE`、`TYP_TEMPLATE`。

## License

MIT
