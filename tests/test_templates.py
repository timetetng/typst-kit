"""模板回归测试：python3 -m unittest discover -s tests -v（需要 typst）。"""

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("typst"), "需要 typst")
class TemplatesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="typst-kit-test-")
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.packages = self.work / "packages"
        package = self.packages / "local/mathnote/0.1.0"
        package.mkdir(parents=True)
        shutil.copyfile(ROOT / "lib/mathnote.typ", package / "lib.typ")
        shutil.copyfile(
            ROOT / "typst-package/local/mathnote/0.1.0/typst.toml",
            package / "typst.toml",
        )

    def compile(self, source):
        path = self.work / "test.typ"
        path.write_text(source, encoding="utf-8")
        result = subprocess.run(
            ["typst", "compile", "--package-path", str(self.packages),
             str(path), str(self.work / "test.pdf")],
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return path

    def test_homework_helpers_and_aliases(self):
        template = (ROOT / "templates/homework.typ").read_text()
        self.assertNotIn("#let ", template)
        self.compile(template.replace("__TITLE__", "作业测试") + """
#problem(source: "P42")[生成子群 $gen(H, K)$，嵌套 $gen(a^(p^(n-1)))$。]
+ $Aut(G), Hol(G), Ker(f)$
+ #circled(1)
#解[解答。]
#证明[证明。]
#solution(qed: true)[英文解答别名。]
#proof[英文证明别名。]
#eqn($a,b = c;d$, $(*)$)
#problem[填空：#填空(w: 2em)]
#pagebreak()
#problem(source: "只写出处")[]
""")

    def test_note_interfaces_and_references(self):
        self.compile("""
#import "@local/mathnote:0.1.0": *
#show: note.with(title: none, tracking: 1.5pt, indent: none, header: false)
= 第一章
#theorem[结论。] <first>
#proof(title: "证明标题")[证明内容。]
#solution(title: "解答标题")[解答内容。]
= 第二章
#definition[定义。] <second>
见 @first 和 @second。
$gen(H, K), Hol(G)$
#eqn($E = m c^2$, $(*)$)
""")

    def test_homework_options(self):
        for options in [
            'header: false',
            'course: "群论", author: "姓名"',
            'id: "123"',
            'author: "姓名", id: "123", size: 12pt, margin: 2cm',
        ]:
            with self.subTest(options=options):
                self.compile(
                    '#import "@local/mathnote:0.1.0": *\n'
                    f'#show: homework.with({options})\n'
                    '#problem[题干。]\n#证明[证明。]\n'
                )

    def test_standalone_is_generated_and_self_contained(self):
        stage = self.work / "stage"
        (stage / "lib").mkdir(parents=True)
        (stage / "templates").mkdir()
        shutil.copyfile(ROOT / "lib/mathnote.typ", stage / "lib/mathnote.typ")
        script = stage / "templates/gen-standalone.sh"
        shutil.copyfile(ROOT / "templates/gen-standalone.sh", script)
        subprocess.run(["bash", str(script)], check=True, capture_output=True)
        generated = (stage / "templates/standalone.typ").read_text()
        self.assertEqual(generated, (ROOT / "templates/standalone.typ").read_text())
        self.assertNotIn("#import ", generated)
        self.compile(generated.replace("__TITLE__", "自包含测试") + """
$gen(H, K), Hol(G)$
#theorem[结论。] <standalone>
#proof(title: "标题")[证明。]
见 @standalone。
""")


if __name__ == "__main__":
    unittest.main()
