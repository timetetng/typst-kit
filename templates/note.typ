// ============================================================
//  数学笔记 · 引用式模板（`typ init` 默认用这个）
//  · 排版定义在本地包 @local/mathnote:0.1.0：改那一处 → 所有笔记一起变
//  · 标题由 `typ init` 用文件名自动填好（下面的 __TITLE__）
//  · 预览：<Space>tp    速查表：~/notes/typst/00-cheatsheet.typ
//  · 完整语法手册：~/notes/typst/typst-manual.typ
//  · 想看写法示例：typ init -t sample
//  · 想要单文件自包含、不引用包：typ init -s <名字>
// ============================================================
#import "@local/mathnote:0.1.0": *

#show: note.with(title: "__TITLE__")

// 可选参数（全部有默认值，只写要改的）：
//   tracking: 1pt      正文字间距
//   title-tracking: 2pt  标题字间距
//   size: 11pt         正文字号
//   margin: 2.4cm      页边距（写一个数 = 四周相同；或 (x: 2.4cm, y: 2.2cm)）
//   indent: 2em        首行缩进（默认就是 2em；写 none 关闭）
//   header: true       页眉显示当前章
// 例子： #show: note.with(title: "__TITLE__", tracking: 1.5pt, indent: none)
//
// 定理环境写法（编号自动「章号.序号」，可交叉引用）：
//   #theorem(title: "介值定理")[ … ] <thm:ivt>            正文里：见 @thm:ivt
//   可用的：theorem lemma corollary proposition definition example
//           axiom assumption claim conjecture（有编号）
//           remark notation solution（无编号）

// ════════════ 正文从这里开始 ════════════
