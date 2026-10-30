// 数学作业 · 引用式模板（typ init -t homework）
// 排版与公共数学函数来自 @local/mathnote:0.1.0。
// 修改库会作用于所有引用式作业；单独分享源码时也需提供本地包。
#import "@local/mathnote:0.1.0": *
// 作业使用普通解答块；保留库中原有的笔记 proof / solution 接口。
#import "@local/mathnote:0.1.0": (
  homework-proof as proof, homework-solution as solution,
)

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
