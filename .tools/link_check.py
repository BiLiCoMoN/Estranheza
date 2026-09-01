import os, re, sys
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
md_files = []
for dirpath, _, filenames in os.walk(root):
    for fn in filenames:
        if fn.lower().endswith('.md'):
            md_files.append(os.path.join(dirpath, fn))

broken = []
for path in md_files:
    try:
        text = open(path, 'r', encoding='utf-8').read()
    except Exception as e:
        print('ERROR_READING', path, e)
        continue
    for m in re.finditer(r'\[[^\]]+\]\(([^)]+)\)', text):
        target = m.group(1).strip()
        if target.startswith(('http://', 'https://', 'mailto:', '#')):
            continue
        target = target.split('#', 1)[0]
        if not target:
            continue
        p = os.path.normpath(os.path.join(os.path.dirname(path), target))
        if not os.path.exists(p):
            broken.append((os.path.relpath(path, root).replace('\\', '/'), target))

concept_files = []
for path in md_files:
    rel = os.path.relpath(path, root).replace('\\', '/')
    if rel.startswith('00-') or rel.startswith('bibliografia') or rel.startswith('.github') or rel.lower().endswith('readme.md') or rel.endswith('ESTRANHEZA.md'):
        continue
    if re.match(r'^(01|02|03|04|05|06|07|08|09)-', rel):
        concept_files.append(rel)

missing_standard = []
for rel in concept_files:
    path = os.path.join(root, rel)
    try:
        text = open(path, 'r', encoding='utf-8').read()
    except Exception:
        continue
    if '### Percurso' not in text or '### Rastreabilidade' not in text:
        missing_standard.append(rel)

print('FILES_CHECKED', len(md_files))
print('BROKEN_RELATIVE_LINKS', len(broken))
for rel, target in broken:
    print('BROKEN', rel, '->', target)
print('MISSING_STANDARD_BLOCKS', len(missing_standard))
for rel in missing_standard:
    print('MISSING', rel)

# Exit non-zero if broken links found
sys.exit(0 if not broken and not missing_standard else 2)
