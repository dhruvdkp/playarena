#!/usr/bin/env python3
"""Post-process pandoc HTML: inject Mermaid JS, custom CSS, and convert mermaid code blocks."""
import re
import html
import sys
from pathlib import Path

src = Path(sys.argv[1])
text = src.read_text()

# Convert <pre class="mermaid"><code>...</code></pre> to <div class="mermaid">decoded</div>
def repl(m):
    body = m.group(1)
    return f'<div class="mermaid">{html.unescape(body)}</div>'

text = re.sub(
    r'<pre class="mermaid"><code>(.*?)</code></pre>',
    repl,
    text,
    flags=re.DOTALL,
)

# CSS tuned to look like a project report
css = """
<style>
@page { size: A4; margin: 1in; }
body { font-family: 'Georgia', 'Times New Roman', serif; font-size: 12pt; line-height: 1.5; color: #111; max-width: 7in; margin: 0 auto; }
h1 { font-size: 22pt; color: #1a5490; border-bottom: 2px solid #1a5490; padding-bottom: 6px; margin-top: 48px; page-break-before: always; text-align: center; }
h1:first-of-type { page-break-before: avoid; }
h2 { font-size: 16pt; color: #1a5490; margin-top: 24px; }
h3 { font-size: 13pt; color: #333; margin-top: 16px; }
p, li { text-align: justify; }
table { border-collapse: collapse; width: 100%; margin: 12px 0; page-break-inside: avoid; font-size: 11pt; }
th, td { border: 1px solid #666; padding: 6px 8px; vertical-align: top; }
th { background: #1a5490; color: white; font-weight: bold; }
tr:nth-child(even) td { background: #eaf2fb; }
code { background: #f4f4f4; padding: 1px 4px; border-radius: 3px; font-size: 90%; }
pre { background: #f4f4f4; border-left: 3px solid #1a5490; padding: 10px; overflow-x: auto; font-size: 10pt; }
.mermaid { text-align: center; margin: 20px auto; padding: 10px; background: white; page-break-inside: avoid; }
em { color: #555; }
blockquote { border-left: 4px solid #1a5490; background: #f9f9f9; padding: 8px 12px; margin: 12px 0; color: #333; }
#TOC { page-break-after: always; }
#TOC ul { list-style: none; padding-left: 20px; }
#TOC > ul { padding-left: 0; }
#TOC a { color: #1a5490; text-decoration: none; }
header#title-block-header { text-align: center; page-break-after: always; padding-top: 2in; }
header#title-block-header h1.title { font-size: 28pt; border: none; }
header#title-block-header .author { font-size: 14pt; margin: 6px 0; }
.center, div.center { text-align: center; }
</style>
"""

mermaid_js = """
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({ startOnLoad: true, theme: 'default', flowchart: { useMaxWidth: true, htmlLabels: true }, sequence: { useMaxWidth: true }, er: { useMaxWidth: true }, class: { useMaxWidth: true } });
</script>
"""

# Inject before </head>
text = text.replace("</head>", css + mermaid_js + "</head>")

src.write_text(text)
print(f"Enhanced {src}")
