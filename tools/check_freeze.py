#!/usr/bin/env python3
"""Check that every page has an up-to-date entry in the committed _freeze/.

The publish workflow (.github/workflows/publish.yml) has no R, so it can only
publish pages whose executed output is already frozen. Quarto re-executes a page
whose _freeze hash doesn't match the md5 of its source, and on the runner that
fails ("Unable to locate an installed version of R"; run 36051532494, 09-24).

Usage: python3 tools/check_freeze.py   (from the repo root; exit 1 on a problem)

Fix a failure by rendering the page locally (`quarto render lessons/<id>.qmd`) and
committing its _freeze/ directory. Note that a page's header box is generated from
lessons.yml, which the hash doesn't cover: after editing lessons.yml, re-render
every page whose header changes.
"""
import glob
import hashlib
import json
import os
import sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
pages = ["index.qmd"] + sorted(glob.glob("lessons/*.qmd", root_dir=root))
problems = []
for page in pages:
    stem = os.path.splitext(page)[0]
    frozen = os.path.join(root, "_freeze", stem, "execute-results", "html.json")
    if not os.path.exists(frozen):
        problems.append(f"{page}: not frozen (no {os.path.relpath(frozen, root)})")
        continue
    with open(os.path.join(root, page), "rb") as f:
        md5 = hashlib.md5(f.read()).hexdigest()
    with open(frozen) as f:
        if json.load(f).get("hash") != md5:
            problems.append(f"{page}: frozen output is stale (source changed since it was rendered)")

for p in problems:
    print(p)
print(f"{len(pages) - len(problems)} of {len(pages)} pages frozen and up to date.")
sys.exit(1 if problems else 0)
