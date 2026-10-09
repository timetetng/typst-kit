// ============================================================
//  typst 数学笔记速查表（本机 typst 0.15.1 实测过的写法）
//  预览：<Space>tp 打开浏览器预览 / <Space>tP 切换 / <Space>ts 停止 / <Space>tc 同步光标
//  输入：前缀 + Tab（补全菜单里选），希腊字母直接打名字让 tinymist 补全
//  自动：数学区里 a1 → a_1；敲 ^ / _ 补成 ^() / _()（<BS> 可整段退）；可视模式 gs 包行内公式 / gS 包行间公式 / ga 包自适应括号；插入模式 <C-l> 把光标前单词包成 $…$（汉字两侧自动补空格）
//  空白：数学区连按 <Space> 1/2/3/4 次 → 普通空格 / #h(0.5em) / quad(1em) / wide(2em)；<BS> 反向降级
//  模板：typ init 新建（引用式，排版来自本地包 @local/mathnote:0.1.0）；typ init -s 自包含；typ init -t homework 作业模板；typ init -h 看选项
//  中英混排：保存时自动补空格 / 转全角标点（`11pt`、`5G`、`UTF-8B` 这类例外不动）；关掉 `vim.g.cjk_auto_space = false`，整篇手动 `:CJKFix`
//  格式化：保存时 typstyle 自动折行（80 列）+ 缩进（2 空格）+ 按字母重排 import 项
// ============================================================
#set page(paper: "a4", margin: (x: 1.6cm, y: 1.5cm))
#set text(
  font: ("New Computer Modern", "Noto Serif CJK SC"),
  size: 9.5pt,
  lang: "zh",
  region: "cn",
)
#show math.equation: set text(font: "New Computer Modern Math")
#set heading(numbering: "1.")
#show heading: set block(above: 0.9em, below: 0.5em)
#set table(stroke: 0.4pt + luma(200), inset: 4pt, align: (left, left, left))
#show table.cell.where(y: 0): set text(weight: "bold")

#align(center)[#text(size: 15pt, weight: "bold")[typst 数学笔记速查表]]

= 模板与引用

排版定义全在本地包 `@local/mathnote:0.1.0`（实体文件：`~/.config/typ/lib/mathnote.typ`）—— 改那一处，所有引用式笔记一起变。

#table(
  columns: (auto, 1fr),
  [操作], [说明],
  [`typ init`],
  [新建笔记（默认「引用式」）：头部只有 `#import "@local/mathnote:0.1.0": *` 和 `#show: note.with(title: "…")`],

  [`typ init -s`],
  [改用自包含模板 `standalone.typ`：排版整段写进文件、不依赖本地包，单个文件能直接发给别人],

  [`typ init -t sample`], [带示例的模板，学写法用；`typ init -h` 看全部选项],

  [`typ init -t homework`],
  [**作业模板**（自包含、不依赖本地包）：`#show: homework.with(title: "…", course: "…", author: "…", id: "…")`（后三个进页眉），正文用 `#problem[题干]`（`source:` 挂灰字出处）、`#解[…]` / `#证明[…]`（自动补 □）、`#填空(w: 2em)`；题号单级递增 + 悬挂缩进，小问直接写 `+` 列表（自动 (1)(2)，缩进与题干齐平）。详见 `typst-manual.typ` 的「作业模板」一节],
  [入口函数],
  [`#show: note.with(title: "标题")` —— 页面、字体、字间距、标题块都靠它带进来],

  [可调参数],
  [`note.with(…)` 还能传 `tracking:`（正文字间距，默认 1pt）、`title-tracking:`（标题，默认 2pt）、`size:`（默认 11pt）、`margin:`（默认 2.4cm × 2.2cm）、`indent:`（首行缩进，默认 `2em`；写 `none` 关闭）、`header:`（页眉是否显示当前章，默认 `true`）],

  [单篇微调],
  [写成 `#show: note.with(title: "…", tracking: 1pt)` —— 只影响这一篇，不动库],

  [改全部],
  [编辑 `~/.config/typ/lib/mathnote.typ`（软链到包目录），下次编译即生效],

  [覆写环境],
  [同名重定义即可遮蔽：`#let theorem(body, title: none) = …`；或 `#import "@local/mathnote:0.1.0": theorem as base` 后包一层],

  [原理],
  [typst 的 `#set` / `#show` 只在定义它的文件作用域生效、不跨文件传播 ⇒ 库把 set/show 全放进 `note()` 函数体，靠 `#show: note.with(…)` 带进你的文件],
)

= 输入方式

#table(
  columns: (auto, 1fr),
  [操作], [说明],
  [前缀 + `Tab`],
  [在补全菜单里选片段（本表「触发」列）；只在数学区出现的片段不会在正文里误触],

  [希腊字母],
  [直接打名字：`alp` → `alpha`，`lam` → `lambda`，`sig` → `sigma`（tinymist 补全）],

  [自动下标],
  [数学区里 `a1` 自动变 `a_1`；`ab2` 这种多字母不动，`x_1` 后再打 2 不会重复加 `_`],

  [`^` / `_` 自动补括号],
  [数学区里敲 `^` 或 `_` 直接补成 `^()` / `_()`，光标落在括号中间（多字符上下标如 `a^(12)` 省得手打括号）。*必须是圆括号*：typst 数学里 `{}` 不是分组，`a^{12}` 不报错但会渲染成字面的 `a{12}`，上标丢了。正文里的 `^`（字面量）和 `_`（强调）不碰，代码块里也不碰。`<BS>` 对称：光标停在空括号中间时一次退格把 `^()` 整段删掉],

  [`$` 自动配对],
  [正文里敲 `$` 自动补成 `$…$` 光标停中间；再敲 `$` 直接跳过收尾；全角 `￥` 也认作 `$`（忘了切输入法不用回去改）],

  [连按空格],
  [数学区里连按 `<Space>`：1 次普通空格（只是分隔语法，渲染宽度 0）→ 2 次 `#h(0.5em)` → 3 次 `quad`（1em）→ 4 次 `wide`（2em）；第 5 次起只是普通空格。`<BS>` 反向：光标紧跟间隙命令时一次退格整段删掉并降一级（`wide`→`quad`→`#h(0.5em)`→删掉，普通空格那级是正常退格）。手写的 `quad` / `#h(0.5em)` 不会被升级误伤],

  [`gs` / `gS` / `ga`],
  [可视模式选中后：包行内公式 / 包行间公式 / 包自适应括号。行内公式（`gs`）会自动在汉字与 `$…$` 之间补空格 —— typst 数学区里的空格不产生视觉宽度，不补就会「集合$H$是」紧贴；已在空格旁边则不重复补],

  [`<C-l>`],
  [插入模式：把光标前那个单词一键包成 `$…$`（`集合H是` → `集合 $H$ 是`），汉字两侧同样自动补空格。在数学区 / 代码块里、或光标前不是单词则无操作],

  [中英混排],
  [打字时就即时补空格；保存时再整篇整理一遍：中英之间、中文与数字之间补半角空格；数字与单位之间补空格（`10kg` → `10 kg`）；正文标点转全角；代码 / 公式里标点转半角；全角标点后残留的空格删掉。不想让它动就 `vim.g.cjk_auto_space = false`；整篇手动跑 `:CJKFix`。例外：`11pt` / `2.5em` 这类长度单位不拆，`5G` / `UTF-8B` / `100C` 不做单位加空格],
)

= 结构类片段

#table(
  columns: (auto, auto, 1fr),
  [触发], [得到], [说明],
  [`ff` / `frac`], [$(a)/(b)$], [分式],
  [`sq`], [$sqrt(x)$], [根号],
  [`rt`], [$root(3, x)$], [n 次根],
  [`lr`], [$lr((a+b)/c)$], [自适应括号（括号要写在里面）],
  [`abs`], [$abs(x)$], [绝对值],
  [`norm`], [$norm(x)$], [范数],
  [`floor` / `ceil` / `round`], [$floor(x)$ / $ceil(x)$ / $round(x)$], [取整],
  [`binom`], [$binom(n, k)$], [二项式系数],
  [`eq`], [$&=$], [多行公式的对齐点（行尾用 `\` 换行）],
)

= 求和 / 积分 / 极限

#table(
  columns: (auto, auto, 1fr),
  [触发], [得到], [说明],
  [`sum`], [$sum_(n=1)^oo$], [求和（连乘用 `prod`）],
  [`int`], [$integral_a^b f dif x$], [定积分],
  [`iint` / `iiint`], [$integral.double_D$ / $integral.triple_V$], [重积分],
  [`oint`], [$integral.cont_C$], [环路积分],
  [`lim`], [$lim_(x -> 0)$], [极限（`limsup` / `liminf`）],
  [`ddx` / `pdx`],
  [$(dif f)/(dif x)$ / $(partial f)/(partial x)$],
  [导数 / 偏导],

  [`ddt` / `pdt`],
  [$(dif f)/(dif t)$ / $(partial f)/(partial t)$],
  [对时间求导],
)

= 矩阵 / 向量 / 分段

#table(
  columns: (auto, auto, 1fr),
  [触发], [得到], [说明],
  [`mat`], [$mat(delim: "(", 1, 2; 3, 4)$], [圆括号矩阵],
  [`bmat`], [$mat(delim: "[", 1, 2; 3, 4)$], [方括号矩阵],
  [`dmat`], [$mat(delim: "|", a, b; c, d)$], [行列式],
  [`vec`], [$vec(1, 2, 3)$], [列向量],
  [`cases`], [$cases(x & "if" x > 0, -x & "else")$], [分段函数],
)

= 集合 / 逻辑

#table(
  columns: (auto, auto, auto, auto, 1fr),
  [触发], [得到], [触发], [得到], [说明],
  [`in`], [$in$], [`notin`], [$in.not$], [属于 / 不属于],
  [`sub`], [$subset$], [`subeq`], [$subset.eq$], [子集 / 子集或相等],
  [`supset`], [$supset$], [`empty`], [$emptyset$], [超集 / 空集],
  [`inter`],
  [$inter$],
  [`union`],
  [$union$],
  [交 / 并（大写 `interbig` / `unionbig`）],

  [`forall`], [$forall$], [`exists`], [$exists$], [任意 / 存在],
  [`implies`], [$=>$], [`iff`], [$<=>$], [推出 / 等价],
  [`mapsto`], [$mapsto$], [`to`], [$->$], [映射到 / 趋于],
  [`RR`], [$RR$], [`NN`], [$NN$], [实数集 / 自然数集（`ZZ` `QQ` `CC`）],
  [`aleph0`], [$aleph_0$], [`oo`], [$oo$], [可数无穷 / 无穷],
)

= 运算符 / 关系 / 常量

#table(
  columns: (auto, auto, auto, auto),
  [触发], [得到], [触发], [得到],
  [`times`], [$times$], [`cdot`], [$dot.op$],
  [`pm`], [$plus.minus$], [`mp`], [$minus.plus$],
  [`leq`], [$<=$], [`geq`], [$>=$],
  [`neq`], [$!=$], [`approx`], [$approx$],
  [`equiv`], [$equiv$], [`prop`], [$prop$],
  [`dif`], [$dif$（微分算子 d）], [`partialop`], [$partial$],
  [`nabla`], [$nabla$], [`qed`], [$square$（□，证毕符号）],
)

= 标记 / 字体

#table(
  columns: (auto, auto, auto, auto),
  [触发], [得到], [触发], [得到],
  [`hat`], [$hat(x)$], [`bar`], [$overline(x)$（共轭/均值）],
  [`under`], [$underline(x)$], [`dot`], [$dot(x)$],
  [`ddot`], [$dot.double(x)$], [`til`], [$tilde(x)$],
  [`arv`], [$arrow(x)$], [`cal`], [$cal(L)$],
  [`bb`], [$bb(R)$], [`boldv`], [$bold(v)$],
)

= 正文类片段

#table(
  columns: (auto, auto, 1fr),
  [触发], [得到], [说明],
  [`mk`], [`$ $`], [行内公式（光标在中间）],
  [`dm`], [`$` 换行 … 换行 `$`], [行间公式],
  [`thm` / `lem` / `cor`],
  [`#theorem(title: "…")[…]`],
  [定理 / 引理 / 推论（蓝/绿/蓝色条）],

  [`prope` / `defn` / `exm`],
  [`#proposition[…]` / `#definition[…]` / `#example[…]`],
  [命题 / 定义 / 例],

  [`axm` / `asm` / `clm` / `cnj`],
  [`#axiom[…]` / `#assumption[…]` / `#claim[…]` / `#conjecture[…]`],
  [公理 / 假设 / 断言 / 猜想（紫色条）],

  [`rem` / `nota` / `solu`],
  [`#remark[…]` / `#notation[…]` / `#solution[…]`],
  [注 / 记号 / 解（灰条，不编号）],

  [`prf`],
  [`#proof[…]`],
  [证明（结尾自动补 □；可写 `#proof(title: "定理 1.1")[…]`）],

  [`eqn` / `circ`],
  [`#eqn($ a+b=c $, $(*)$)` / `#circled(1)`],
  [公式居中 + 右侧手写标号（不参与 @ 引用）/ 圈号 ①（1–20）],

  [`fig`], [`#figure(image("…"), caption: […])<fig:…>`], [插图],
  [`tbl`], [`#figure(table(…), caption: […])<tab:…>`], [表格],
  [`todo`], [`#text(fill: red)[TODO: …]`], [待办标记],
)

= 常用排版写法（直接照抄）

#table(
  columns: (auto, 1fr),
  [需求], [写法],
  [行内公式], [`$f(x) = x^2$`],
  [行间公式], [`$` 换行 `  integral_0^1 f(x) dif x` 换行 `$`],
  [多行对齐], [`$ x &= y \` 换行 `&= z $`（`&` 对齐，行尾 `\` 换行）],
  [公式编号],
  [模板里*不编号*（推理步骤不需要）。要编号就自己写 `#set math.equation(numbering: "(1)")`；行内/行间的分界是 `$` 内侧有没有空格],

  [标题],
  [`= 一级` / `== 二级` / `=== 三级`（`#set heading(numbering: "1.1")` 自动编号）],

  [列表], [`- 无序` / `+ 有序` / `1. 数字`],
  [交叉引用],
  [在元素后面写 `<标签>`（如 `#theorem[…] <thm:ivt>`、`#figure(…)<fig:x>`），正文里写 `@thm:ivt` 引用；定理/定义会渲染成「定理 1.1」并自动跳转，*跨章也正确*。标签名随意，建议 `前缀:名字`（`thm:` `def:` `fig:` `tab:` `eq:`）],

  [公式里的空白],
  [`a #h(0.5em) b`（0.5em）/ `a quad b`（1em）/ `a wide b`（2em）/ `thin` `med` `thick`（1/6、2/9、5/18 em）。上面「连按空格」就是它。注意 `quad` / `wide` 后面要留一个空格，否则 `a quadb` 会被 typst 当成一个叫 `quadb` 的变量],

  [代码块], [```python 换行 … 换行 ```],
  [定理环境],
  [模板已定义 13 个：`theorem` `lemma` `corollary` `proposition` `definition` `example` `axiom` `assumption` `claim` `conjecture`（有编号）+ `remark` `notation` `solution`（无编号）。编号自动是「章号.序号」，且*所有有编号环境共用一条序列*（定理 1.1 → 引理 1.2 → 定义 1.3 ……），换章归零（第 2 章第一个编号环境 → 2.1）；没用一级标题时退化成 1、2。可选参数：`title:` 给环境加个说明（`#definition(title: "群")[…]`）],
)

= md 和 typst 怎么选

- *md 适合*：纯文字、给别的工具读、GitHub 上直接看。公式靠 `$…$` 让渲染器（KaTeX）转。
- *typst 适合*：公式多、要排版（编号、定理环境、图表引用）、想一键出 PDF。
- 结论：数学笔记用 typst；typst 源码可读性问题，靠本速查表 + 片段（`sum` → `sum_(n=1)^oo`）基本抹平——
  写的时候打的是「sum」不是「`sum_(n=1)^oo`」，读的时候看到的是渲染结果（`<Space>tp` 预览）。
