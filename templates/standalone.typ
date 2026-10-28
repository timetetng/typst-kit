// ============================================================
//  数学笔记 · 自包含模板（`typ init -s` 用这个）
//  ⚠ 本文件由 gen-standalone.sh 从 mathnote.typ 自动生成，不要手改
//    改库之后跑：bash ~/.config/typ/templates/gen-standalone.sh
//  · 排版定义整段都在这个文件里，不 import 本地包 —— 单文件自包含、能直接发给别人
//  · 标题由 `typ init` 用文件名自动填好（下面的 __TITLE__）
//  · 预览：<Space>tp    速查表：~/notes/typst/00-cheatsheet.typ
//  · 想「改一处、所有笔记同步」：用默认模板（引用 @local/mathnote:0.1.0）
// ============================================================

// ── 定理类环境 ──────────────────────────────────────────
// 编号 = 章号.本章序号，**所有编号环境共用一个序列**：第 2 章里第一个编号环境（不论
// 是定理还是定义/例/推论…）是 2.1，紧接着的下一个是 2.2；换章自动归零。
// 没用一级标题时退化成 1,2,3…
// 实现用 figure：只有 figure / heading / 公式才能被 `@标签` 交叉引用。
//   #theorem(title: "介值定理")[ … ] <thm:ivt>
//   引用：见 @thm:ivt        → 渲染「见 定理 1.1」并自动跳转
//
// ⚠ 编号为什么这么绕：典型的「定理 1.1」计数器是 figure 自己的 counter，但
//   ① counter 的值里没有章号（figure 的 counter 是 Typst 自动维护的，手动 update
//      写进去的数组会被下一次 step 覆盖）,② numbering 回调里现场查 counter(heading)
//      拿到的是「回调被求值处」的章号 —— 所以 @引用 会把「定理 1.1」显示成「定理 2.1」.
//   于是：章号在**环境自身的位置**算好（context + counter(heading).get())，把
//   (章号, 序号) 存进 state 并埋进环境的 metadata;@引用 时按位置把编号取回来。
#let _fmt(a) = if a.len() >= 2 {
  numbering("1.1", ..a)
} else {
  numbering("1", ..a)
}

// 全局共享计数器的值：(章号, 序号)；没有一级标题时退化成单级 (序号,)
// 所有编号环境共用一个 state —— 不管 kind 是什么，都排同一条序列
#let _c = state("mathnote-count", ())

// kind → 中文名（供 @引用 使用）
#let _all-kinds = (
  "theorem": [定理],
  "lemma": [引理],
  "corollary": [推论],
  "proposition": [命题],
  "definition": [定义],
  "example": [例],
  "axiom": [公理],
  "assumption": [假设],
  "claim": [断言],
  "conjecture": [猜想],
  "remark": [注],
  "notation": [笔记],
  "solution": [解],
)

// 环境外壳：灰底 + 左侧色条；n-str = none 表示不显示编号（注、记号、解）
#let _e-shell(name, color, title, n-str, body) = block(
  width: 100%,
  inset: (x: 9pt, y: 7pt),
  radius: 3pt,
  stroke: (left: 2.2pt + color),
  fill: luma(247),
  breakable: true,
)[
  // figure 的内容默认居中（图要居中），定理环境必须覆盖回左对齐
  #set align(left)
  // 定理/定义/注这类环境内部**不缩进**：它们由短段落组成，跟着正文缩进会像被套了一层
  #set par(first-line-indent: 0pt)
  #text(weight: "bold", fill: color)[
    #name#(if n-str != none [ #n-str])#(if title != none [ （#title)])
  ]
  #h(0.5em)
  #body
]

// 参与共享计数器（每章归零）的编号环境（顺序无关）
#let _numbered-kinds = (
  "theorem",
  "lemma",
  "corollary",
  "proposition",
  "definition",
  "example",
  "axiom",
  "assumption",
  "claim",
  "conjecture",
)

#let _env(
  name,
  kind,
  body,
  title: none,
  color: rgb("#2f6f4f"),
  numbered: true,
) = {
  if numbered {
    figure(
      kind: kind,
      supplement: name,
      numbering: none, // 编号自己画（见上），引用由 note() 里的 show ref 接住
      caption: none,
      outlined: false, // 定理环境不该出现在「插图目录」里
      gap: 0pt,
    )[
      #context {
        // 位置就在环境处 ⇒ 这里拿到的章号是本环境所在的章
        let chap = counter(heading).get().at(0, default: 0)
        _c.update(d => {
          // 与 kind 无关 ⇒ 所有编号环境共用一条序列；上一章（或还没编号）从头开始
          let prev-chap = if d.len() >= 2 { d.at(0) } else { 0 }
          let n = if d.len() > 0 and prev-chap == chap { d.last() + 1 } else {
            1
          }
          if chap == 0 { (n,) } else { (chap, n) }
        })
      }
      #context {
        // ⚠ 必须另起一个 context：同一个 context 里 update 之后 get 还看不到新值
        let v = _c.at(here())
        // 编号埋进 metadata:@引用 时按位置取回，就不会算成引用处所在章的章号
        [#metadata(v) <mn-num>#_e-shell(name, color, title, _fmt(v), body)]
      }
    ]
  } else {
    figure(
      kind: kind,
      supplement: name,
      numbering: none,
      caption: none,
      outlined: false,
      gap: 0pt,
    )[#_e-shell(name, color, title, none, body)]
  }
}

#let theorem(body, title: none) = _env([定理], "theorem", body, title: title)
#let lemma(body, title: none) = _env(
  [引理],
  "lemma",
  body,
  title: title,
  color: rgb("#3f5f9f"),
)
#let corollary(body, title: none) = _env(
  [推论],
  "corollary",
  body,
  title: title,
  color: rgb("#3f5f9f"),
)
#let proposition(body, title: none) = _env(
  [命题],
  "proposition",
  body,
  title: title,
  color: rgb("#3f5f9f"),
)
#let definition(body, title: none) = _env(
  [定义],
  "definition",
  body,
  title: title,
  color: rgb("#8a5a00"),
)
#let example(body, title: none) = _env(
  [例],
  "example",
  body,
  title: title,
  color: rgb("#8a5a00"),
)
#let axiom(body, title: none) = _env(
  [公理],
  "axiom",
  body,
  title: title,
  color: rgb("#6a3f9f"),
)
#let assumption(body, title: none) = _env(
  [假设],
  "assumption",
  body,
  title: title,
  color: rgb("#6a3f9f"),
)
#let claim(body, title: none) = _env(
  [断言],
  "claim",
  body,
  title: title,
  color: rgb("#3f5f9f"),
)
#let conjecture(body, title: none) = _env(
  [猜想],
  "conjecture",
  body,
  title: title,
  color: rgb("#6a3f9f"),
)

// ── 不计编号的环境 ──────────────────────────────────────
#let remark(body, title: none) = _env(
  [注],
  "remark",
  body,
  title: title,
  color: luma(120),
  numbered: false,
)
#let notation(body, title: none) = _env(
  [记号],
  "notation",
  body,
  title: title,
  color: luma(120),
  numbered: false,
)
#let solution(body, title: none) = _env(
  [解],
  "solution",
  body,
  title: title,
  color: luma(120),
  numbered: false,
)

// 证明：中文不用斜体（西文斜体对汉字是伪斜体，很难看），改加粗；结尾 □（空心方块）= $square$
#let proof(body, title: none) = block(
  width: 100%,
  above: 0.6em,
  below: 0.9em,
  breakable: true,
)[
  // 证明内部也不缩进（与定理环境一致）
  #set par(first-line-indent: 0pt)
  #text(weight: "bold")[证明#(if title != none [ （#title)])]#h(0.4em)
  #body
  #h(1fr)
  #box[$square$]
]

// ── 有限群常用算子 ──────────────────────────────────────
// 直接写 $Aut(G)$、$Ker(f)$、$Syl_p(G)$；使用 op 保留正体与算子间距。
// 只定义多字母名称，不改变 G、H、Z、C、N 等单字母变量。
// Typst 已内置的 exp、gcd、lcm、deg、dim、det 等继续使用内置定义。
#let Aut = math.op("Aut")
#let Inn = math.op("Inn")
#let Out = math.op("Out")
#let Hom = math.op("Hom")
#let End = math.op("End")
#let Ker = math.op("Ker")
#let ker = math.op("ker")
#let Im = math.op("Im")
#let im = math.op("im")
#let Coker = math.op("Coker")
#let coker = math.op("coker")
#let Coim = math.op("Coim")
#let coim = math.op("coim")
#let id = math.op("id")
#let ord = math.op("ord")
#let rank = math.op("rank")
#let tr = math.op("tr")

// 子群、共轭类与根基；Phi / Omega 等名称保留给 Typst 的希腊字母。
#let Sym = math.op("Sym")
#let Alt = math.op("Alt")
#let Syl = math.op("Syl")
#let Hall = math.op("Hall")
#let Cl = math.op("Cl")
#let core = math.op("core")
#let Core = math.op("Core")
#let Soc = math.op("Soc")
#let Fit = math.op("Fit")
#let Fitt = math.op("Fitt")
#let Rad = math.op("Rad")
#let Frat = math.op("Frat")

// 特征标及表示论。
#let Irr = math.op("Irr")
#let IBr = math.op("IBr")
#let Lin = math.op("Lin")
#let Res = math.op("Res")
#let Ind = math.op("Ind")
#let Inf = math.op("Inf")
#let Def = math.op("Def")

// 常见经典群。
#let GL = math.op("GL")
#let SL = math.op("SL")
#let PGL = math.op("PGL")
#let PSL = math.op("PSL")
#let GU = math.op("GU")
#let SU = math.op("SU")
#let PGU = math.op("PGU")
#let PSU = math.op("PSU")
#let Sp = math.op("Sp")
#let PSp = math.op("PSp")
#let GO = math.op("GO")
#let SO = math.op("SO")
#let PSO = math.op("PSO")

// ── 辅助 ────────────────────────────────────────────────
// 生成子群：$gen(H)$、$gen(H, K)$，尖括号随内容高度自适应。
#let gen(..generators) = math.lr(
  sym.chevron.l + generators.pos().join($,$) + sym.chevron.r,
)

// 圈号序号：circled(1) → ① … circled(20) → ⑳（超出 20 退化成 (21))
// 用来标证明步骤：$#circled(1)$,$#circled(2)$，或正文里 #circled(1)
#let _circled-table = (
  "①",
  "②",
  "③",
  "④",
  "⑤",
  "⑥",
  "⑦",
  "⑧",
  "⑨",
  "⑩",
  "⑪",
  "⑫",
  "⑬",
  "⑭",
  "⑮",
  "⑯",
  "⑰",
  "⑱",
  "⑲",
  "⑳",
)
#let circled(n) = {
  let i = if type(n) == int { n } else { int(n) }
  if i >= 1 and i <= 20 { _circled-table.at(i - 1) } else { "(" + str(i) + ")" }
}

// 行间公式 + 右侧手动标号：不参与交叉引用，纯粹方便正文里指认（「由 (*) 得」).
//   #eqn($ a + b = c $, $(*)$)
//   #eqn($ a + b = c $, "(1)")
// 标号与引用处写法保持一致即可（都用 $(*)$，或都用 "(*)").
#let eqn(body, mark) = {
  // ⚠ 必须把 equation 元素**整体**交给 math.display。写成 body.body 会取出「已文本化」的
  //   内容：E,m 这类单字母变量会丢掉数学上下文、渲染成正体（只有 ^ / _ / frac 等结构
  //   里的变量还保持斜体）—— 实测 `E = m 𝑐2`，而正确结果是 `𝐸 = 𝑚𝑐2`.
  let b = if type(body) == content and body.func() == math.equation {
    math.display(body)
  } else {
    body
  }
  block(above: 0.9em, below: 0.9em, width: 100%)[
    #grid(
      columns: (1fr, auto),
      align: (center + horizon, right),
      b, mark,
    )
  ]
}

// ── 入口：整篇文档的排版都在这个函数里 ──────────────────
// ⚠ 所有 set/show 必须写在函数体内 —— Typst 的 set/show 只在定义它的
//   文件作用域生效，写在文件顶层的话 import 方一点也继承不到。
//
// 可调参数（其余样式想改就直接改本文件）:
//   title          页面大标题；none = 不显示标题块
//   tracking       正文字间距（默认 1pt)
//   title-tracking 页面大标题字间距（默认 2pt)
//   size           正文字号
//   margin         页边距
//   indent         中文首行缩进，默认 2em（两个汉字）；写 none 关闭
//   header         是否在页眉显示当前章（默认 true)
#let note(
  title: none,
  body,
  tracking: 1pt,
  title-tracking: 2pt,
  size: 11pt,
  margin: (x: 2.4cm, y: 2.2cm),
  indent: 2em,
  header: true,
) = {
  set page(
    paper: "a4",
    margin: margin,
    numbering: "1",
    // 页眉：左侧「章号 章标题」。取本页第一个一级标题（若本页没有章标题，
    // 则沿用前面最近的一章），这样同一页里跨两章时不会提前打成下一章的页眉
    header: if header {
      context {
        let p = here().page()
        let hs = query(heading.where(level: 1))
        let cur = hs.filter(h => h.location().page() >= p).at(0, default: none)
        let ch = if cur != none { cur } else {
          hs.filter(h => h.location().page() < p).last(default: none)
        }
        if ch != none {
          set text(size: 8.5pt, fill: luma(120))
          numbering("1.", counter(heading).at(ch.location()).at(0))
          [#h(0.5em)#ch.body]
        }
      }
    } else { none },
  )
  set text(
    // covers：让西文/西文标点归 New Computer Modern，汉字归思源宋体
    font: (
      (name: "New Computer Modern", covers: "latin-in-cjk"),
      "Noto Serif CJK SC",
    ),
    size: size,
    lang: "zh",
    region: "cn",
    tracking: tracking,
  )
  // 公式间距由 math 自己管，不受 tracking 影响；中文字符（"…"里的文字）用宋体兜底
  show math.equation: set text(
    font: ("New Computer Modern Math", "Noto Serif CJK SC"),
  )
  // 数学里的逗号/分号后统一补 0.3em 间距：源码保持 $a,b$ 即可，正文里的半角逗号不受影响
  // ⚠ 必须用 content 相加（it + h(...))；写成 [it#h(...)] 会把 it 当字面文本渲染出来
  // ⚠ 手动写的 #h(...)/quad 会与本规则叠加，旧笔记可逐步清理
  show math.equation: eq => {
    show ",": it => it + h(0.3em)
    show ";": it => it + h(0.3em)
    eq
  }
  show raw: set text(tracking: 0pt) // 等宽代码不跟随字间距（否则代码行会变宽、容易折行）
  set par(justify: true, leading: 0.75em)
  // ⚠ `set` 写在 `if` 块里只在块内生效（typst 的 set 作用域规则）,
  // 所以这里必须无条件 set，用表达式决定缩进值
  set par(
    first-line-indent: if indent == none { 0pt } else {
      (amount: indent, all: true)
    },
  )
  set heading(numbering: "1.1")
  show raw.where(block: true): set block(
    inset: 8pt,
    radius: 3pt,
    fill: luma(248),
  )

  // 行间公式**统一不编号**：推理步骤占绝大多数，编号只会变成视觉噪声。
  // 需要指名某条公式时，用文字描述（「上式」「定义 1.1 的第 3 条」）或引用它所在的定理/定义。
  // ⚠ 之所以不自己数：Typst 内置的 equation counter 装不下章号，而自定编号又无法只对
  //   「带标签的公式」生效（it.label / element.label / selector(label) 都不存在，实测）.
  set math.equation(numbering: none)
  show math.equation.where(block: true): set block(above: 0.9em, below: 0.9em)

  // @引用：把目标环境/公式埋在 metadata 里的编号取回来（详见文件开头 _c 的说明）
  show ref: it => {
    let el = it.element
    if el == none {
      return it
    }
    if (
      el.func() != figure or type(el.kind) != str or el.kind not in _all-kinds
    ) {
      return it
    }
    let name = _all-kinds.at(el.kind)
    if el.kind in _numbered-kinds {
      let found = query(selector(<mn-num>).after(el.location())).at(
        0,
        default: none,
      )
      if found != none {
        return link(it.target, [#name #(_fmt(found.value))])
      }
    }
    link(it.target, [#name])
  }

  if title != none {
    align(center)[
      #text(size: 17pt, weight: "bold", tracking: title-tracking)[#title]
      #v(2pt)
      #text(size: 10pt, fill: luma(110))[#(
        datetime.today().display("[year]-[month]-[day]")
      )]
    ]
    v(0.6em)
  }
  body
}

// ════════════ 正文从这里开始 ════════════
#show: note.with(title: "__TITLE__")
