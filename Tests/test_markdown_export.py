#!/usr/bin/env python3
"""Exercise the built DocsGen CLI against disposable documentation trees."""
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import unquote

command = sys.argv[1:]
if not command:
    raise SystemExit('Usage: python3 Tests/test_markdown_export.py dotnet Bin/Debug/DocsGen.dll')
command = [str(Path(arg).resolve()) if Path(arg).is_file() else arg for arg in command]

def run(*args, ok=True):
    result = subprocess.run(command + list(map(str, args)), capture_output=True, text=True)
    assert (result.returncode == 0) == ok, result.stdout + result.stderr
    return result

def write(root, name, body, header=''):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('---\ntitle: ' + name + '\n' + header + '---\n' + body)

with tempfile.TemporaryDirectory(prefix='docsgen-markdown-') as folder:
    root = Path(folder) / 'docs'
    root.mkdir()
    config = 'output: _site\ntitle: Export fixture\nfullfilename: true\nmarkdown-base-url: https://docs.example.test/product/\nsinglefile-skip: Leaf.md\n'
    (root / '_config').write_text(config)
    write(root, 'index.md', 'Root content.\n', 'index: Section/index.md\nindex: Leaf.md#one\nindex: Leaf.md#two\nindex: Section/index.md\n')
    write(root, 'Section/index.md', '{% include /_fragment.md %}\n', 'mount: ../Shared/ as Mounted\n')
    write(root, 'Shared/index.md', 'Mounted root.\n', 'index: Child.md\n')
    write(root, 'Shared/Child.md', 'Mounted child {{ relative_path }}.\n')
    write(root, 'Shared/Hidden.md', 'HIDDEN BODY', 'hidden: true\n')
    write(root, 'Leaf.md', '    indented code\n\n## A heading\n\n```markdown\n# code heading\n[x](unchanged.md)\n```\n\n| A | B |\n|---|---|\n| 1 | 2 |\n')
    write(root, 'Orphan.md', 'Unlisted page.\n')
    write(root, 'Hidden.md', 'HIDDEN BODY', 'hidden: true\n')
    (root / '_fragment.md').write_text('Included {{ page_title }} at {{ relative_path }}.\n')
    write(root, '_drafts/Private.md', 'PRIVATE BODY')
    export = root / '_site/index_all.md'

    # Coverage must include unlisted/mounted pages, without repeats or private inputs.
    run('markdown', root)
    data = export.read_bytes()
    corpus = data.decode()
    pages = [unquote(x) for x in re.findall(r'<!-- docsgen:page-begin (.*?) -->', corpus)]
    assert pages == ['index.md', 'Section/index.md', 'Section/Mounted/index.md', 'Section/Mounted/Child.md', 'Leaf.md', 'Orphan.md', 'Shared/Child.md', 'Shared/index.md'], pages
    assert 'HIDDEN BODY' not in corpus and 'PRIVATE BODY' not in corpus
    assert 'Included Section/index.md at Section/index.md.' in corpus
    assert 'Mounted child Section/Mounted/Child.md.' in corpus
    assert 'https://docs.example.test/product/Section/Mounted/Child/index.html' in corpus
    assert '    indented code\n' in corpus
    assert '```markdown\n# code heading\n[x](unchanged.md)\n```' in corpus
    assert '| A | B |\n|---|---|\n| 1 | 2 |' in corpus
    assert b'\r' not in data and not data.startswith(b'\xef\xbb\xbf')

    # Reruns must be byte-stable and must not ingest the previous export.
    run('markdown', root)
    assert export.read_bytes() == data
    alternate = Path(folder) / 'corpus.md'
    run('markdown', root, alternate, 'https://override.example.test/')
    assert 'Source: [View original page](<https://override.example.test/index.html>)' in alternate.read_text()
    (root / '_config').write_text(config.replace('markdown-base-url: https://docs.example.test/product/\n', ''))
    run('markdown', root, alternate)
    assert 'Source: [View original page](</index.html>)' in alternate.read_text()

    # Output validation must reject source overwrite, re-ingestion and invalid site roots.
    original = (root / 'index.md').read_bytes()
    run('markdown', root, root / 'index.md', ok=False)
    run('markdown', root, root / 'corpus.md', ok=False)
    run('markdown', root, alternate, 'file:///private', ok=False)
    run('markdown', root, alternate, 'https://example.test/?query=1', ok=False)
    assert (root / 'index.md').read_bytes() == original

    # Template failures must not replace the last complete export with an error string.
    write(root, 'Broken.md', '{% include /_does_not_exist.md %}')
    before = export.read_bytes()
    run('markdown', root, ok=False)
    assert export.read_bytes() == before
    (root / 'Broken.md').unlink()

    # Build opt-in must produce the same corpus without changing generated HTML.
    (root / '_config').write_text(config)
    run('build', root)
    html = {p.relative_to(root / '_site'): p.read_bytes() for p in (root / '_site').rglob('*.html')}
    (root / '_config').write_text(config + 'markdown: true\n')
    run('build', root)
    assert export.read_bytes() == data
    assert html == {p.relative_to(root / '_site'): p.read_bytes() for p in (root / '_site').rglob('*.html')}

    # Actual navigation cycles must still fail and preserve the previous corpus.
    write(root, 'Cycle.md', 'Cycle content.', 'index: Cycle.md\n')
    root_page = (root / 'index.md').read_text()
    (root / 'index.md').write_text(root_page.replace('title: index.md\n', 'title: index.md\nindex: Cycle.md\n'))
    before = export.read_bytes()
    run('markdown', root, ok=False)
    assert export.read_bytes() == before
    (root / 'index.md').write_text(root_page)
    (root / 'Cycle.md').unlink()

    # Hidden pages remain excluded even when the caller enables edit mode.
    run('--edit', 'markdown', root)
    assert 'HIDDEN BODY' not in export.read_text()

    # Generated-reference and path filters affect only Markdown, preserving authored API pages.
    write(root, 'API/Generated.md', 'GENERATED_REFERENCE', 'status: auto: generated\n')
    write(root, 'API/Concepts.md', 'AUTHORED_API_CONCEPTS')
    run('markdown', root)
    assert 'GENERATED_REFERENCE' in export.read_text()
    run('--overrideoption=markdown-skip-generated:true', 'markdown', root)
    assert 'GENERATED_REFERENCE' not in export.read_text()
    assert 'AUTHORED_API_CONCEPTS' in export.read_text()
    run('--overrideoption=markdown-skip:API/*', 'markdown', root)
    assert 'AUTHORED_API_CONCEPTS' not in export.read_text()
    run('--overrideoption=markdown-skip-generated:true', 'build', root)
    assert any('GENERATED_REFERENCE' in p.read_text() for p in (root / '_site').rglob('*.html'))

print('Markdown export integration checks passed.')
