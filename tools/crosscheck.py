#!/usr/bin/env python3
"""Cross-check the lesson outlines against each other (#9).

Reads outlines/<id>.md (the "Picks up" and "Promises / leaves open" sections) and
lessons.yml (lesson ids and prerequisites), and reports:

  1. lessons with no outline;
  2. lesson ids in hooks that don't exist in lessons.yml;
  3. promises not acknowledged: A promises X -> B, but B's "Picks up" never names A
     (anywhere in an item, so a pointer or E2 Recall counts);
  4. pick-ups not announced: B picks up X from A, but A's "Promises" never names B
     (anywhere in an item, so "a pointer to `B`" counts);
  5. pick-ups from a lesson that isn't a prerequisite (directly or through the chain),
     so a reader may not have seen it yet;
  6. hooks marked "unpaid";
  7. front to back: in the first-course path, a pick-up from a lesson that comes
     *later* in the path (the reader can't have seen it, even as an "if you've
     done X" Recall).

Pick-ups marked as E2 Recalls ("if you've done", or "E2") are allowed from
non-prerequisites (PROTOCOL.md §4), so section 5 lists them separately.

Usage:
  python3 tools/crosscheck.py                       # outlines/ in the working tree
  python3 tools/crosscheck.py --ref origin/8-outlines-irt --ref origin/8-outlines-uses
      # also read outlines from these git refs (later refs win for the same file)
  python3 tools/crosscheck.py > notes/crosscheck-pass-1.md

Parsing is by convention (see outlines/_template.md): lesson ids appear in
backticks; a pick-up names its source as "(from `id`)" or "(thread from `id`)", and
a promise names its target(s) after "→".
"""
import argparse
import re
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
ID = re.compile(r"`([a-z0-9][a-z0-9-]*)`")


def read_outlines(refs):
    texts = {}
    for f in sorted((ROOT / "outlines").glob("*.md")):
        if not f.name.startswith("_"):
            texts[f.stem] = f.read_text()
    for ref in refs:
        names = subprocess.run(["git", "-C", str(ROOT), "ls-tree", "--name-only", ref, "outlines/"],
                               capture_output=True, text=True, check=True).stdout.split()
        for n in names:
            stem = Path(n).stem
            if n.endswith(".md") and not Path(n).name.startswith("_"):
                texts[stem] = subprocess.run(["git", "-C", str(ROOT), "show", f"{ref}:{n}"],
                                             capture_output=True, text=True, check=True).stdout
    return texts


def section(text, heading):
    m = re.search(rf"^## {re.escape(heading)}\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    if not m:
        return []
    body = re.sub(r"<!--.*?-->", "", m.group(1), flags=re.S)
    # one item per top-level bullet, continuation lines folded in
    items, cur = [], None
    for line in body.splitlines():
        if line.startswith("- "):
            if cur is not None:
                items.append(cur)
            cur = line[2:]
        elif cur is not None and line.strip():
            cur += " " + line.strip()
    if cur is not None:
        items.append(cur)
    return [i for i in items if i.strip() and i.strip().lower() not in ("none.", "none")]


def pickups(text):
    out = []
    for item in section(text, "Picks up"):
        srcs = re.findall(r"\((?:[^()]*?\bfrom|thread from)\s+((?:`[^`]+`(?:,\s*|\s+and\s+|\s*/\s*)?)+)", item)
        ids = [i for s in srcs for i in ID.findall(s)]
        out.append((item, ids))
    return out


def promises(text):
    out = []
    for item in section(text, "Promises / leaves open"):
        if "→" in item:
            head, tail = item.split("→", 1)
            ids = ID.findall(tail)
        else:
            head, ids = item, []
        unpaid = bool(re.search(r"\bunpaid\b", item, re.I))
        out.append((item, ids, unpaid))
    return out


def ancestors(lid, prereqs, seen=None):
    seen = set() if seen is None else seen
    for p in prereqs.get(lid, []):
        if p not in seen:
            seen.add(p)
            ancestors(p, prereqs, seen)
    return seen


def short(s, n=110):
    s = re.sub(r"\s+", " ", s).strip()
    return s if len(s) <= n else s[: n - 1] + "…"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ref", action="append", default=[], help="git ref to read outlines from")
    args = ap.parse_args()

    course = yaml.safe_load((ROOT / "lessons.yml").read_text())
    lessons = {l["id"]: l for l in course["lessons"]}
    prereqs = {i: list(l.get("prereqs") or []) for i, l in lessons.items()}
    texts = read_outlines(args.ref)

    P = {k: pickups(v) for k, v in texts.items()}
    R = {k: promises(v) for k, v in texts.items()}

    missing = [i for i in lessons if i not in texts]
    unknown, unack, unannounced, order, unpaid = [], [], [], [], []

    for a, items in R.items():
        for item, ids, is_unpaid in items:
            if is_unpaid:
                unpaid.append((a, item))
            for b in ids:
                if b not in lessons:
                    unknown.append((a, "promise", b, item))
                elif b in texts and b != a and not any(a in ID.findall(it) for it, _ in P[b]):
                    unack.append((a, b, item))

    for b, items in P.items():
        anc = ancestors(b, prereqs)
        for item, srcs in items:
            for a in srcs:
                if a not in lessons:
                    unknown.append((b, "pick-up", a, item))
                    continue
                if a in texts and not any(b in ID.findall(it) for it, _, _ in R[a]):
                    unannounced.append((b, a, item))
                if a != b and a not in anc:
                    order.append((b, a, item))

    w = sys.stdout.write
    w(f"# Cross-check report\n\nOutlines read: {len(texts)} of {len(lessons)} lessons"
      + (f" (refs: {', '.join(args.ref)})" if args.ref else "") + ".\n\n")

    w(f"## 1. Lessons with no outline ({len(missing)})\n\n")
    w("".join(f"- `{i}` ({lessons[i]['module']})\n" for i in missing) or "None.\n")

    w(f"\n## 2. Unknown lesson ids ({len(unknown)})\n\n")
    w("".join(f"- `{a}` {kind} names `{b}`: {short(item)}\n" for a, kind, b, item in unknown) or "None.\n")

    w(f"\n## 3. Promises not acknowledged by the target ({len(unack)})\n\n"
      "A promises something to B, but B's *Picks up* doesn't name A. Either B should pick it up, or A should point elsewhere.\n\n")
    w("".join(f"- `{a}` → `{b}`: {short(item)}\n" for a, b, item in sorted(unack)) or "None.\n")

    w(f"\n## 4. Pick-ups not announced by the source ({len(unannounced)})\n\n"
      "B picks something up from A, but A's *Promises* doesn't name B. Usually A's promise list needs a line.\n\n")
    w("".join(f"- `{b}` ← `{a}`: {short(item)}\n" for b, a, item in sorted(unannounced)) or "None.\n")

    is_e2 = lambda item: bool(re.search(r"if you'?ve done|\bE2\b", item, re.I))
    bare = [o for o in order if not is_e2(o[2])]
    e2 = [o for o in order if is_e2(o[2])]
    w(f"\n## 5. Pick-ups from a lesson that isn't a prerequisite ({len(bare)}, plus {len(e2)} marked as E2 Recalls)\n\n"
      "B relies on A, but A isn't among B's prerequisites (directly or through the chain), so a reader may not have seen it. "
      "Either add the prerequisite, or make it a brief \"if you've done A\" Recall (E2) that restates what B needs.\n\n")
    w("".join(f"- `{b}` ← `{a}`: {short(item)}\n" for b, a, item in sorted(bare)) or "None.\n")

    w(f"\n## 6. Hooks marked unpaid ({len(unpaid)})\n\n")
    w("".join(f"- `{a}`: {short(item)}\n" for a, item in sorted(unpaid)) or "None.\n")

    path = next((p["lessons"] for p in course.get("paths", []) if p["id"] == "first-course"), [])
    pos = {x: i for i, x in enumerate(path)}
    backward = [(b, a, item) for b in path if b in P for item, srcs in P[b]
                for a in srcs if a in pos and pos[a] > pos[b]]
    w(f"\n## 7. Front to back: pick-ups from later in the first-course path ({len(backward)})\n\n"
      "B comes before A in the first-course path but picks something up from A. Reorder the path, "
      "or have B teach it and A recall it.\n\n")
    w("".join(f"- `{b}` (#{pos[b] + 1}) ← `{a}` (#{pos[a] + 1}): {short(item)}\n" for b, a, item in backward) or "None.\n")


if __name__ == "__main__":
    main()
