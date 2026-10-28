// ============================================================
//  数学作业 · 自包含模板（`typ init -t homework`）
//  · 排版定义整段写在本文件里，不 import 本地包 —— 单文件可直接发给别人
//  · 标题由 `typ init` 用文件名自动填好（下面的 __TITLE__）
//  · 预览：<Space>tp    速查表：~/notes/typst/00-cheatsheet.typ
//  · 与数学笔记（@local/mathnote）的差别：没有定理环境、没有章号，
//    全局只有「题」一个编号维度；解答用加粗的「解」/「证明」起头
// ============================================================

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

// ── 文档骨架 ───────────────────────────────────────────────
#let homework(
  title: "作业",
  course: none, // 课程名（页眉左侧）
  author: none, // 姓名（页眉右侧）
  id: none, // 学号
  date: datetime.today(),
  size: 11pt,
  margin: (x: 2.2cm, y: 2.0cm),
  header: true,
  body,
) = {
  set page(
    paper: "a4",
    margin: margin,
    header: if header {
      context {
        set text(size: 8.5pt, fill: luma(120))
        let who = if author != none and id != none [
          #author　学号 #id
        ] else if author != none [
          #author
        ] else if id != none [
          学号 #id
        ] else {
          []
        }
        grid(
          columns: (1fr, auto),
          if course != none { [#course] } else { [] }, who,
        )
      }
    } else { none },
    footer: context {
      set align(center)
      set text(size: 9pt, fill: luma(120))
      [第 #counter(page).display() 页 / 共 #counter(page).final().last() 页]
    },
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
    tracking: 1pt,
  )
  show math.equation: set text(
    font: ("New Computer Modern Math", "Noto Serif CJK SC"),
  )
  // 数学里的逗号/分号后统一补 0.3em 间距：源码保持 $a,b$ 即可
  show math.equation: eq => {
    show ",": it => it + h(0.3em)
    show ";": it => it + h(0.3em)
    eq
  }
  show raw: set text(tracking: 0pt)
  set par(
    justify: true,
    leading: 0.75em,
    first-line-indent: (amount: 2em, all: true),
  )
  set enum(numbering: "(1)", indent: 1.15em) // 题内小问默认 (1)、(2)…，缩进到与题干文字齐平
  set list(indent: 1.15em)
  // 行间公式不编号：作业里的公式是推理步骤，编号只会成为噪声
  set math.equation(numbering: none)
  show math.equation.where(block: true): set block(above: 0.9em, below: 0.9em)
  show raw.where(block: true): set block(
    inset: 8pt,
    radius: 3pt,
    fill: luma(248),
  )

  // 标题块（课程/姓名/学号在页眉，这里只放作业名与日期）
  align(center)[
    #text(size: 16pt, weight: "bold", tracking: 2pt)[#title]
    #v(2pt)
    #text(size: 10pt, fill: luma(110))[#date.display("[year]-[month]-[day]")]
  ]
  v(0.7em)
  line(length: 100%, stroke: 0.5pt + luma(190))
  v(0.9em)

  body
}

// ── 题号计数器 ─────────────────────────────────────────────
// 作业没有章号，编号退化成单级递增：1、2、3…（改题/补题不会乱号）
#let _pnum = counter("hw-problem")

// ── 题目 ──────────────────────────────────────────────────
// 用法
//   #problem[题干…]                        自动编号 + 抄录题干
//   #problem(source: "P42 习题 3")[题干…]   题号后挂出处
//   #problem(source: "P42 习题 3")[]        只写出处、不抄题干（[] 不能省）
// ⚠️ 题干是**必填的位置参数**，所以 trailing 方块要放在命名参数后面不能省。
//    （Typst 不允许「带默认值的位置参数」，因此这里没法让 body 可省。）
#let problem(
  body,
  source: none,
  above: 2.6em,
  below: 0.6em,
) = {
  _pnum.step()
  // 悬挂缩进：题号顶格（与解答的「解」左边缘齐），题干文字与续行都对齐到 1.15em。
  // ⚠️ 这里**不能用 block 包住正文**：实测 typst 0.15.1 下 `set par(hanging-indent:)`
  //    一旦落在 block 容器里就失效（续行会顶格）；所以用 `v()` 手动造上下间距。
  v(above, weak: true)
  set par(first-line-indent: 0pt, hanging-indent: 1.15em)
  context [
    #box(width: 1.15em, align(left)[*#_pnum.display("1.")*]) #body#if source != none [ #text(size: 0.88em, fill: luma(120), tracking: 0pt)[（#source）]]
  ]
  v(below)
}

// ── 解答 ───────────────────────────────────────────────────
// 与笔记里的 #proof 同款：不加底色的块，开头一个加粗标签。
// 中文不用斜体（对汉字是伪斜体），所以标签加粗而不是倾斜。
#let _answer(label, body, qed: false, above: 0.6em, below: 1.2em) = block(
  width: 100%,
  above: above,
  below: below,
  breakable: true,
)[
  #set par(first-line-indent: 0pt)
  #text(weight: "bold")[#label]#h(0.4em)
  #body
  #if qed [
    #h(1fr)
    #box[$square$] // 空心方块，笔记库同款
  ]
]

#let 解(body, qed: false) = _answer([解], body, qed: qed)
#let 证明(body) = _answer([证明], body, qed: true)
// 西文别名（习惯写英文时用）
#let solution(body, qed: false) = 解(body, qed: qed)
#let proof(body) = 证明(body)

// ── 填空横线 ───────────────────────────────────────────────
#let 填空(w: 3em) = box(
  width: w,
  height: 1.1em,
  stroke: (bottom: 0.6pt + luma(110)),
)[]

// ── 正文从这里开始 ═════════════════════════════════════════
// 下面两行二选一：只写作业名，或连课程/姓名/学号一起写（它们会进页眉）
#show: homework.with(title: "__TITLE__")
// #show: homework.with(title: "__TITLE__", course: "群论", author: "姓名", id: "学号")

// #problem[题干…]
// #证明[ … ]
// #解[ … ]
//
// 题内小问直接写 + 列表（默认 (1)、(2)…）：
// + 第一小问
// + 第二小问
//
// 选择题四个选项横排：
// #grid(columns: (1fr,) * 4)[A. …][B. …][C. …][D. …]
