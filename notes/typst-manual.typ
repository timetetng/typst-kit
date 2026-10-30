// ============================================================
//  Typst 语法手册（本机版）
//  · 对象：typst 0.15.1（本机 pacman 版）；文中写法都在本机实测过
//  · 排版用本地包 @local/mathnote:0.1.0（`typ init` 默认模板）
//  · 速查表（一页纸）：~/notes/typst/00-cheatsheet.typ
//  · 官方文档本地镜像：~/.pi/agent/skills/typst-math-cn/docs-0.15.0-en/
//  · 预览：<Space>tp   编译：typ compile   新建笔记：typ init
// ============================================================
#import "@local/mathnote:0.1.0": *

#show: note.with(title: "Typst 语法手册", tracking: 1pt)

#text(size: 9.5pt, fill: luma(110))[
  本手册按「从写一篇笔记需要什么」的顺序组织：先看工作流，再是文档结构、数学、定理与引用、图表、
  排版控制、中文排版、报错排查、命令行。每节尽量给「能直接抄」的最小示例。
]

= 本机工作流

== 一篇笔记的完整生命周期

```typst
typ init 群论笔记          # 新建（引用式模板：排版来自本地包）
                           #   —— 标题自动用文件名填好，光标停在「正文从这里开始」
nvim 群论笔记.typ          # 写；<Space>tp 开浏览器实时预览，<Space>ts 停
typ compile                # 编译当前目录的 .typ（默认出 PDF）
```

#table(
  columns: (auto, 1fr),
  table.header([命令], [作用]),
  [`typ init [名字]`], [新建引用式笔记（不写名字 = 日期时间）],
  [`typ init -s [名字]`], [自包含模板（排版整段写进文件，能直接发给别人）],
  [`typ init -t sample`], [带示例的模板（学写法）],
  [`typ init -t homework [名字]`],
  [作业模板（引用本地包）：`#problem` / `#解` / `#证明` / `#填空`，见下节「作业模板」],

  [`typ compile [文件] [参数…]`], [编译；`-` 开头的参数原样传给 `typst`],
  [`typ cheatsheet`], [打开一页纸速查表],
  [`typ snippets` / `--stats`], [打开/统计补全片段定义],
)

== 编辑体验（nvim 里已经配好的）

- *片段*：打前缀 + `Tab`（`ff` → `$(a)/(b)$`，`sum` → `$sum_(n=1)^oo$`，`thm` → 定理环境……）
- *希腊字母*：直接打名字让 tinymist 补全（`alp` → `alpha`）
- *自动下标*：数学区 `a1` → `a_1`
- *`^`/`_` 自动补圆括号*：`x^` → `x^()`，光标停括号里
- *`$` 自动配对*：正文里敲 `$` 补成 `$…$`
- *可视模式*：`gs` 包行内公式（汉字两侧自动补空格）/ `gS` 包行间公式 / `ga` 包自适应括号
- *插入模式一键包公式*：`<C-l>` 把光标前的单词包成 `$…$`（`集合H是` → `集合 $H$ 是`），汉字两侧自动补空格
- *连按空格*：数学区 1/2/3/4 次 → 普通空格 / `#h(0.5em)` / `quad` / `wide`；`<BS>` 反向降级
- *保存时*：typstyle 自动格式化（80 列折行、2 空格缩进、import 项按字母重排）+ 中英混排自动补空格

== 作业模板（homework）

写作业用 `typ init -t homework <名字>`。它和笔记一样导入本地包 `@local/mathnote:0.1.0`，共用算子、`gen()` 等辅助函数及基础排版；模板在 `~/.config/typ/templates/homework.typ`。

和笔记模板的分工：笔记是「边读边查」，所以有 13 个定理环境和「章号.序号」引用机制；作业是「题 → 小问 → 解答」的嵌套结构、题目本身是常态，套灰底定理环境会满屏便签，所以作业默认使用*单级题号 + 悬挂缩进 + 加粗题号*，不套笔记的定理样式。模板将 `proof` / `solution` 别名指向作业解答块，不改变笔记库原来的同名接口。分享源码时也需提供本地包；旧的自包含作业不会随库自动更新。

```typst
#show: homework.with(title: "第九章作业", course: "群论", author: "姓名", id: "学号")

#problem[设 $G$ 是群，$a, b in G$。证明 $(a b)^(-1) = b^(-1) a^(-1)$。]
#证明[因为 $(a b)(b^(-1) a^(-1)) = a e a^(-1) = e$，故……]   // 行末自动补 □

#problem(source: "P42 习题 3")[判断下列集合是否成群：]
+ $bb(Z)$ 上定义 $a * b = a + b - 1$；   // 自动 (1)(2)，缩进与题干文字齐平
+ $bb(Q)^+$ 上定义 $a * b = (a b)/2$。
#解[逐条验证封闭、结合、单位元、逆元。]
```

#table(
  columns: (auto, 1fr),
  table.header([组件], [作用]),
  [`#problem(body, source: none)`],
  [题号 + 题干。题号单级自动递增、*顶格悬挂*（题干文字与续行对齐到题号之后），`source:` 以灰字挂在题干末尾],

  [`#解[…]` / `#solution[…]`], [加粗「解」开头的解答块],
  [`#证明[…]` / `#proof[…]`], [同上，但行末自动补 □（空心方块）],
  [`#填空(w: 3em)`], [填空横线；省略 `w:` 用默认宽度],
  [`homework.with(…)`],
  [可调 `title`、`course`、`author`、`id`（后三个进页眉，缺省不显示）、`date`、`size`、`margin`、`header`（页眉开关）],
)

⚠️ 两个实测坑：① 题干是*必填*位置参数 —— typst 里带默认值的位置参数不能再接收位置实参，所以「可选 trailing content」做不出来；只写出处就写 `#problem(source: "P42 习题 3")[]`。② 在数学区里调用它必须用命名参数：`#填空(2em)` 会被当成 `2 e m` 而报 `unexpected argument`，要写 `#填空(w: 2em)`。

= 文档结构

== 标题

```typst
= 一级标题        // 章
== 二级标题       // 节
=== 三级标题      // 小节
```

编号、样式靠 `set` / `show` 控制（模板里已经设好 `"1.1"` 式编号）：

```typst
#set heading(numbering: "1.1")                    // 1.1、1.2、2.1…
#set heading(numbering: "1.", supplement: [章])   // 引用时显示「章 3」
#show heading.where(level: 1): set text(size: 16pt)   // 只改一级标题字号
#show heading: set block(above: 1.2em, below: 0.6em)  // 标题上下留白
```

== 段落、换行、强调

```typst
这是第一段。段与段之间空一行即可分段。

这是第二段。
强制换行用 `\`（行尾反斜杠）或 #linebreak()。
```

行内标记：

#table(
  columns: (auto, 1fr),
  table.header([写法], [效果]),
  [`*粗体*`], [*粗体*（单星号，不是 `**`）],
  [`_斜体_`], [_斜体_],
  [`` `等宽` ``], [`等宽`],
  [`#text(fill: red)[红字]`], [#text(fill: red)[红字]],
  [`$x^2$`], [行内公式 $x^2$],
  [`-语- `], [不推荐，用 `#strike[...]`],
  [`#underline[...]`], [#underline[下划线]],
  [`~`], [不断行空格],
)

⚠️ `**粗体**` 会报 `warning: no text within stars` 并渲染成字面的 `*粗体*`——typst 的强调是单个 `*`。

== 列表

```typst
- 无序项
- 第二项
  - 缩进两格 = 子项

+ 有序项（自动编号）
+ 第二项

1. 手动编号的项（一般不用，交给 `+`）
2. 第二项
```

密集列表用 `#list(tight: false)` / `#enum(tight: false)` 控制行距。

== 引用、脚注、链接

```typst
> 这是一段引用。
#quote(block: true, attribution: [某本书])[引文]

这里有脚注#footnote[脚注内容]。

#link("https://typst.app")[typst 官网]
<https://typst.app>            // 自动识别为链接
```

= 数学排版

== 行内公式与行间公式

```typst
行内公式 $f(x) = x^2 + 2x + 1$ 写在句子中间。

行间公式要在 $ 内侧留空格：

$ integral_0^oo e^(-x^2) dif x = sqrt(pi)/2 $
```

行内公式想用「行间」的显示样式（上下标、分式变大）：

```typst
#show math.equation.where(block: false): math.display
```

== 上下标与分组

```typst
$a_1$            $x^(n+1)$        $a_1^2$        $sum_(n=1)^oo$
$a_(i j)$        // 多字符要圆括号
```

⚠️ *typst 数学里 `{}` 不是分组*：`$a^{2}$` 不报错，但渲染成字面的 `a{2}`（上标丢了）。
一律用圆括号：`$a^(2)$`。上下标默认只吃一个字符，`$a^12$` 得到 `a^1 2`。

== 常用符号与函数

#table(
  columns: (auto, 1fr, 1fr),
  table.header([需求], [写法], [备注]),
  [分式], [`$(a)/(b)$` 或 `$frac(a, b)$`], [行内会自动用小号],
  [根式], [`$sqrt(x)$`、`$root(3, x)$`], [],
  [自适应括号],
  [`$lr((a+b)/c)$`、`$lr(\[x\])$`],
  [括号写在里面；`\\(` `\\)` 转义],

  [绝对值/范数], [`$abs(x)$`、`$norm(x)$`], [],
  [取整], [`$floor(x)$`、`$ceil(x)$`、`$round(x)$`], [],
  [二项式], [`$binom(n, k)$`], [],
  [求和/连乘], [`$sum_(n=1)^oo$`、`$product_(k=1)^n$`], [],
  [积分],
  [`$integral_a^b f(x) dif x$`],
  [二重 `integral.double_D`，环路 `integral.cont_C`],

  [导数], [`$(dif f)/(dif x)$`、`$(partial f)/(partial x)$`], [`dif` 是正体 d],
  [极限], [`$lim_(x -> 0)$`、`$limsup_(n->oo)$`], [],
  [集合], [`$in$`、`$subset.eq$`、`$union$`、`$inter$`、`$emptyset$`], [],
  [数集], [`$RR$`、`$NN$`、`$ZZ$`、`$QQ$`、`$CC$`], [黑板体],
  [逻辑], [`$forall$`、`$exists$`、`$=>$`、`$<=>$`、`$!=$`], [],
  [箭头], [`$->$`（趋于）、`$mapsto$`（映射到）、`$arrow(x)$`], [],
  [花体/粗体], [`$cal(L)$`、`$scr(B)$`、`$bb(R)$`、`$bold(v)$`], [],
  [直立], [`$upright(i)$`（虚数单位）、`$bold(upright(H))$`], [],
)

完整符号表：官方文档的 «Symbols» 页（本地镜像 `docs-0.15.0-en/reference/symbols/`），
或 `python3 ~/.pi/agent/skills/typst-math-cn/scripts/search-api.py "<关键词>"`。

== 多行公式与对齐

```typst
$
  (a+b)^2 &= a^2 + 2 a b + b^2 \
          &= a^2 + b^2 + 2 a b
$
```

`&` 是对齐点（每行一个），`\` 换行。多个对齐列就写多个 `&`。

== 矩阵、向量、分段函数

```typst
$ mat(1, 2; 3, 4) $                    // 圆括号矩阵；分号分行
$ mat(delim: "[", 1, 2; 3, 4) $        // 方括号
$ mat(delim: "|", a, b; c, d) $        // 行列式
$ vec(1, 2, 3) $                       // 列向量
$ cases(x & "if" x >= 0, -x & "else") $ // 分段函数：逗号分隔分支
```

⚠️ `cases` 里*不能用 `\` 换行*（会 `warning: linebreaks are ignored in branches`），用逗号分隔。
想控制对齐可以 `#set math.cases(gap: 0.4em)`。

== 公式里的空白

数学区的源码空格*渲染宽度为零*（只是分隔符）：`$a,b$` 和 `$a, b$` 一模一样。要真空白得显式给：

```typst
$a #h(0.5em) b$        // 0.5em
$a quad b$             // 1em（quad 后必须留空格！否则 $a quadb$ 报 unknown variable: quadb）
$a wide b$             // 2em
$a thin b$             // 1/6 em；还有 med(2/9)、thick(5/18)
```

连按空格片段就是自动生成上面这些（见「本机工作流」）。

== 公式编号

模板里*行间公式一律不编号*（推理步骤占绝大多数，编号只会变成视觉噪声）。所以 `$ … $` 与 `$x$` 的区别只是排版样式：

```typst
行内 $x^2$ 跟着文字走；行间 $ x^2 $（$ 内侧留了空格）独占一行、居中。
```

需要指名某条公式时，用文字说（「上式」「定义 1.1 的第 3 条」），或引用它所在的定理 / 定义 —— 那些有编号，`@thm:ivt` 就能指过去。

真要给公式编号（写论文时），自己在 `#show: note.with(…)` 之后开一行：

```typst
#set math.equation(numbering: "(1)")       // 之后所有行间公式编号 (1)(2)…
#set math.equation(numbering: "(1.1)")     // 也可用「章.序号」格式
```

== 标号与圈号（辅助）

证明里想指认某条公式，就用手写标号贴在公式右边（纯粹排版，不参与 `@` 交叉引用）：

```typst
#eqn($ a + b = c $, $(*)$)     // 公式居中，(∗) 贴右边
由 $(*)$ 得……                   // 引用处写法与标号一致即可
```

分步证明的点用圈号（1–20 自动变 ①…⑳，超出退化成 `(21)`）：

```typst
$#circled(1)$ 先证存在性，$#circled(2)$ 再证唯一性   // 数学区里也能用
#circled(3) 正文里同样可用
```

两者都只是排版糖，不含计数逻辑 —— 你手写几号就是几号。

⚠ 改 `eqn` 实现时注意：传给 `math.display` 的必须是*整条公式*（equation 元素），不要用它的 `.body` —— `.body` 已经被「文本化」，`E`、`m` 这类单字母变量的数学上下文会丢，渲染成正体（只有 `^`、`_`、`frac` 这类结构里的变量还是斜体）。

== 公式里的中文与标点

一条原则：*属于公式的放 `$` 内，属于句子的放 `$` 外*。判断标准只有一个 —— 这个标点／汉字是「数学的一部分」还是「中文句子的一部分」。

=== 标点

- *数学语法里的 `,` `;`*（分隔变量、条件、并列式）：写在 `$` 内。typst 会排成数学标点，后面只留约 1.8pt 的薄间隙（普通空格是 3.1pt），正是数学排版想要的样子：
  `$forall a, b in G, a b = a c => b = c$`。
- *句子的标点*（连接两个独立公式、或收尾）：写在 `$` 外；紧贴公式时用半角 `.` `,` `;`（见「中文排版要点」的约定），后面紧跟另一个公式时要手打一个空格，否则会黏成 `,c`：`$a = b$, $c = d$`。
- *行间（居中）公式后面*：标点写在 `$` 外会*单独占一行*（块级元素），所以要么不加标点（中文数学书里很常见），要么写进 `$` 里面：`$ a = b. $`。
- 别用全角标点紧贴数学：全角「，」不带数学间隙，看着松垮（实测全角句号宽 15.9pt，半角 8pt）。

=== 中文

- *短词*（且、或、使得、当且仅当、其中、s.t.）：直接写在 `$` 里，用字符串语法 `"…"`。typst 渲染成正体中文并在两侧自动留数学间隙（实测 3.7pt），不用手打空格：`$a = b "且" c = d$`、`$exists b "s.t." a b = e$`。这是 LaTeX `\text{…}` 的等价物。
- *成句的中文*（「由定理 1.1 知」「由于 $phi$ 与 $tau$ 都是满射」这种三四个字以上、带标点的）：*断开数学环境*，中文写回文本区：`$forall a in G$，由于 $phi$ 是满射，存在 $b in G$ 使 $phi(b) = a$.`。数学区没有中文断行与标点挤压，长中文会把公式撑断、换行难看；而且它本来就不是公式的一部分。
- 两种写法的视觉差距极小（3.7pt vs 3.8pt），所以*按语义选*：公式的语法词用 `"…"`，叙述就断开。

=== 数学区的中文要设字体

中文字体排在数学字体之前时必须写 `covers`，否则中文字体会被当成数学基准字体、间距乱掉（模板已处理）：

```typst
#show math.equation: set text(font: (
  (name: "New Computer Modern Math", covers: "latin-in-cjk"),
  "Noto Serif CJK SC",
))
```

= 定理环境与交叉引用

== 用法

```typst
#theorem(title: "介值定理")[
  若 $f$ 在 $[a, b]$ 上连续……则存在 $xi$ 使 $f(xi) = c$。
] <thm:ivt>

引用：由 @thm:ivt 与 @def:continuity 得……
```

渲染成「定理 1.1」，`@` 引用会显示同样的编号并自动跳转（*跨章也正确*：第 2 章里引第 1 章的定理，仍显示 1.1）。

编号是*所有有编号环境共用的一条序列*：定理 1.1 → 引理 1.2 → 定义 1.3 → 例 1.4 ……，
换章归零（第 2 章第一个编号环境 → 2.1）；没用一级标题时退化成 1、2。

可用环境（模板定义）：

#table(
  columns: (auto, 1fr),
  table.header([有编号], [无编号]),
  [`theorem` `lemma` `corollary` `proposition` `definition` `example`],
  [`remark` `notation` `solution`],

  [`axiom` `assumption` `claim` `conjecture`], [],
)

都支持 `title:` 参数（加括号说明，如 `#definition(title: "群")[…]`）。
证明环境会自动把 `□`（空心方块）推到行末（不必自己写「证毕」）。

```typst
#proof[
  取 $xi = sup S$，由连续性得 $f(xi) = c$。
]
#proof(title: "定理 1.1")[……]      // 想标明在证什么
```

== 为什么这么实现（原理，改模板时会用到）

typst 官方的 `figure` / `math.equation` 计数器只存*单级序号*，装不下章号：

- 手动 `counter.update((1, 0))` 塞章号进去，下一个元素自动 step 时会把它冲回 `(2,)`；
- 想用 `numbering: (..nums) => context { counter(heading).get() … }` 现场查章号，则在 `@引用` 时
  会以*引用处*的位置重新求值 → 第 2 章里引第 1 章的定理会显示「定理 2.1」。

所以模板走的是社区标准解法（`ctheorems` 包同一思路，源码见
`~/.cache/typst/packages/preview/ctheorems/1.1.3/lib.typ`）：

1. 用 `state` 手动维护*全局共享*的 `(章号, 序号)`（所有有编号环境排同一条序列，换章归零）；
2. 环境里 `context` 先算章号（`counter(heading).get()`，位置就在环境处，所以拿得到正确的章号），
  把新编号写回 `state`；
3. 再起一个相邻 `context` 把新值读出来，用 `#metadata(值)` 埋进环境内部；
4. 自定义 `show ref`：拿被引元素的 location，`query(selector(<mn-num>).after(loc))` 把编号捞回来。

⚠️ 两个实测坑：*同一个 `context` 里 `state.update` 之后读不到新值*（必须拆成两个相邻 `context`）；
`state.update(回调)` 的回调*必须显式返回*新值（末尾漏写返回值会让 state 变成 `none`）。

= 图表

== 图片

```typst
#figure(
  image("diagram.png", width: 60%),
  caption: [示意图],
)<fig:diagram>

见 @fig:diagram。
```

== 表格

```typst
#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, right),
    table.header([记号], [含义], [写法]),
    [$RR$], [实数集], [`RR`],
    [$in$], [属于], [`in`],
  ),
  caption: [常用记号],
)<tab:symbols>
```

常用表格参数：

#table(
  columns: (auto, 1fr),
  table.header([参数], [说明]),
  [`columns: (auto, 1fr, 2cm)`], [列宽；`1fr` 占剩余空间],
  [`rows:` / `columns:` 里写数字], [等宽列],
  [`table.header(...)`], [表头（跨页时自动重复，加线）],
  [`table.cell(colspan: 2)[…]`], [合并单元格（`rowspan` 同理）],
  [`stroke: none` / `stroke: 0.4pt + luma(200)`], [边框],
  [`inset: 6pt`], [单元格内边距],
  [`table.hline(...)` / `table.vline(...)`], [手动加线],
)

== 图/表编号

`figure` 默认全局编号（1、2、3…，与章号无关），引用写 `@fig:xxx` / `@tab:xxx`。
想改成「章.序」就在模板里给 `set figure(numbering: "1.1")` 并自己维护计数器（本模板没做，因为数学笔记很少用）。

= 代码与等宽

````typst
行内 `code`。

```python
def f(x):
    return x ** 2
```
````

带行号、高亮某行：

```typst
#raw("code", lang: "python", block: true)   // 行内 raw；块级用三个反引号
#show raw.where(block: true): set block(inset: 8pt, radius: 3pt, fill: luma(248))
```

代码块里的字间距不受正文 `tracking` 影响（模板里已单独 `#show raw: set text(tracking: 0pt)`）。

= 排版控制

== `set` 与 `show`

- `set`（设置属性）作用于*当前作用域往后*的元素，不跨文件传播。
- `show`（重写渲染）把元素换成别的东西。

```typst
#set text(size: 11pt)                          // 之后所有文字 11pt
#set par(justify: true, leading: 0.75em)       // 两端对齐 + 行距
#show heading.where(level: 1): it => [「#it.body」]   // 改写一级标题的渲染
#show: doc => { set text(fill: black); doc }   // 包住整篇（模板注入就是这么做）
```

⚠️ *模板注入的原理*：`#show: note.with(title: "…")` 等于把你后面整篇包进 `note` 函数，
而 `set`/`show` 只在定义它的文件作用域生效、不跨文件传播——所以模板把所有的 `set`/`show`
都写在 `note()` 函数体里，靠这一行带进你的文件。

== 页面

```typst
#set page(
  paper: "a4",                       // "a4" / "us-letter" / (width: 10cm, height: 10cm)
  margin: (x: 2.4cm, y: 2.2cm),      // 或 margin: 2.4cm（四周相同）、(top:, bottom:, inside:, outside:)
  numbering: "1",                    // 页码样式；none 关闭
  header: [页眉内容],
  footer: context [#here().page()],  // 可写 context 拿当前位置
  columns: 2,                        // 分栏
  fill: white,
)
#pagebreak()          // 强制分页
#pagebreak(to: "odd") // 跳到奇数页
#colbreak()           // 分栏换栏
```

== 间距与盒子

```typst
#v(1em)                 // 竖直留白（块级）
#h(1em)                 // 水平留白
#h(1fr)                 // 水平撑满（把后面的内容推到右边，如证明末尾的 □）
#box[不换行的一小段]
#block(inset: 6pt, radius: 3pt, fill: luma(245), stroke: (left: 2pt + blue), width: 100%, breakable: true)[…]
#align(center)[居中内容]
#grid(columns: (1fr, auto), [左], [右])
```

== 字体与字号

```typst
#set text(
  font: ("New Computer Modern", "Noto Serif CJK SC"),   // 西文在前、中文在后
  size: 11pt,
  lang: "zh",
  region: "cn",
  tracking: 1pt,        // 字间距（中文行文调 0.5–1.5pt 比较舒服）
  weight: "regular",    // "bold" / 数字 400/700
  style: "normal",      // "italic"
  fill: black,
)
```

本机已装的字体：`New Computer Modern`、`New Computer Modern Math`、`Noto Serif CJK SC`、
`LXGW WenKai GB Screen`、`HYZhongYuanB5`。查系统字体：`typst fonts`（`--variants` 看字重/字形）。

= 中文排版要点

1. *中英混排有自动空格*：typst 0.12+ 靠 `covers` 机制，中文与西文之间的间隙在排版层面处理；
  模板用 `(name: "New Computer Modern", covers: "latin-in-cjk")` 声明「西文字体只负责西文片段」。
2. *标点（本机约定）*：中文叙述用全角「。」「，」「；」；*紧贴数学公式的标点改半角* `.` `,` `;`（公式是夹用的符号串，GB/T 15834—2011 与 CY/T 154—2017 都要求随外文用半角，中文数学教材与专著也通行半角；半角句号还免于和数字 0 混淆）。行内公式写 `$a = b$.`；行间公式的标点写进 `$` 里或直接省略 —— 详见「公式里的中文与标点」。`#set text(lang: "zh")` 负责中文标点的间距规则。
3. *字间距*：中文正文 `tracking: 1pt` 左右、标题 `2pt`；西文和数学不受影响（数学被单独设字体）。
4. *首行缩进*：模板默认已开（`note.with(indent: 2em)`），*正文段落*首行缩进两个汉字。*定理/定义/证明这类环境内部不缩进*（它们由短段落组成，跟着正文缩进会像被套了一层），列表项也不缩进。你自己要手写等价规则是 `#set par(first-line-indent: (amount: 2em, all: true))`（⚠️ 不加 `all: true` 时，块级元素后的第一段不缩进，是西文习惯）；要关掉模板的缩进写 `indent: none`。
5. *行距*：中文用 `#set par(leading: 0.8em)` 左右比较松快；西文常用 `0.65em`。
6. *中英混排与标点的自动化*：nvim 保存时会跑 conform（规则在 `~/dotfiles/nvim/nvim/lua/cjk/init.lua`）：自动补中英之间的空格，把*正文里紧邻汉字*的半角 `, . : ; ! ?` 转成全角，同时把代码／公式／raw 区内的全角标点反向转半角。所以 `$a = b$.` 这种半角标点（前一字符是 `$`、不是汉字）不会被转回全角，可以放心写。

= 报错与排查

== 常见编译错误

#table(
  columns: (auto, 1fr, 1fr),
  table.header([报错], [原因], [处理]),
  [`unknown variable: quadb`], [`quad` / `wide` 后少了空格], [写成 `quad b`],
  [`unexpected argument: ...`],
  [参数名写错（如 `figure` 没有 `inset`）],
  [查 `typst eval` 或文档],

  [`expected expression, found ...`],
  [少了 `#`、括号不配对、`:` 写成 `：`],
  [看报错行],

  [`label <x> does not exist`], [引用了一个没定义的标签], [定义处写 `<x>`],
  [`cannot add length and integer`], [单位缺失（`2em` 不是 `2`）], [补单位],
  [`... is not allowed in math mode`],
  [数学区写了正文语法],
  [用 `\` 转义或移出 `$…$`],
)

== 「不报错但渲染不对」的坑（最值得记住）

#table(
  columns: (auto, 1fr, 1fr),
  table.header([写法], [现象], [正确]),
  [`$a^{2}$`], [渲染成 `a{2}`，上标丢失], [`$a^(2)$`（`{}` 不是分组）],
  [`$a^12$`], [只有 1 是上标], [`$a^(12)$`],
  [`$a,b$` vs `$a, b$`],
  [宽度完全相同（空格零宽）],
  [要空白用 `#h(…)` / `quad`],

  [`**粗体**`], [warning + 字面星号], [`*粗体*`],
  [`cases` 里用 `\` 换行], [warning，分支被忽略], [逗号分隔],
  [数学区 `\h`], [当成变量 h 渲染], [不是换行符；换行用 `\`],
  [中文字体写在数学字体前], [数学间距异常], [加 `covers: "latin-in-cjk"`],
  [`#theorem()[…]`], [空的 `()` 无害但不规范], [`#theorem[…]`],
  [`$$x$`（连写两个 `$`）],
  [报 `unclosed delimiter`，公式吞掉后面全部内容],
  [行内公式写一个 `$`：`$x$`],

  [`$` 内侧留空格],
  [变成行间公式：独占一行、居中（本模板不编号）],
  [要行内就别留内侧空格：`$x$`],
)

== 调试手段

```bash
typst compile --root / a.typ out.pdf     # 看报错（带行列号与源码片段）
typst eval 'repr(query(<label>).map(x => x.value))' --in a.typ   # 查标签处的值
typst query ...                          # 0.15 起已废弃，改用 typst eval
```

- `#context here()` / `#context [#here().page()]`：查看当前位置信息。
- `#repr(x)`：把任意值渲染成可读文本，插在文档里看。
- 排版问题先怀疑「元素被当成块级产生了段间距」，用 `#show ...: set block(above:, below:)` 调。

= 命令行

```bash
typst compile a.typ                 # 出 a.pdf
typst compile --root / a.typ o.pdf  # 指定项目根（模板在 ~/.config/typ 之类的外部路径时需要）
typst watch a.typ                   # 存盘自动重编译（编辑器的预览就是它）
typst eval 'expr' --in a.typ        # 求值（查询/自省）
typst fonts                         # 列出系统字体
typst --version
```

包：

- `@preview/名字:版本`：从网络下载，缓存在 `~/.cache/typst/packages/preview/<名字>/<版本>/`
- `@local/名字:版本`：本地包，放在 `~/.local/share/typst/packages/local/<名字>/<版本>/`
- 本笔记的排版库就是本地包：`@local/mathnote:0.1.0`，实体文件是
  `~/.config/typ/lib/mathnote.typ`（包目录里那个 `lib.typ` 是它的软链）。

= 附录：官方文档在哪儿

#table(
  columns: (auto, 1fr),
  table.header([内容], [路径]),
  [官方文档（英文，0.15）],
  [`~/.pi/agent/skills/typst-math-cn/docs-0.15.0-en/`],

  [官方文档（中文，0.14.2）],
  [`~/.pi/agent/skills/typst-math-cn/docs-0.14.2-zh/`],

  [全量文档索引], [`~/.pi/agent/skills/typst-math-cn/references/docs-index.md`],
  [中文专题（数学、编号、字体、间距…）],
  [`~/.pi/agent/skills/typst-math-cn/references/`],

  [API 检索脚本],
  [`python3 ~/.pi/agent/skills/typst-math-cn/scripts/search-api.py "outline"`],

  [包检索脚本],
  [`python3 ~/.pi/agent/skills/typst-math-cn/scripts/search-packages.py "table"`],

  [在线文档], [`#link("https://typst.app/docs/")[typst.app/docs]`],
)

#v(1fr)
#align(center)[#text(size: 9pt, fill: luma(140))[— 完 —]]
