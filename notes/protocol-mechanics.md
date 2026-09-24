# Mechanics and review checklist: additions for PROTOCOL.md §7 and §9 (#5)

PROTOCOL.md §7 and §9 already carry the mechanics from the pilots. This file lists
only what they are missing or get wrong, for folding in. Each point comes from
something that actually broke while building the pilots or the draft site.

## §7 Mechanics: additions

**Worktrees**
- Each session works in its own git worktree, one per issue, outside Dropbox:
  `git worktree add -b <issue>-<slug> ~/worktrees/irw-course-<issue>-<slug> origin/main`.
  The Dropbox checkout stays on `main` for Ben. Stage explicit paths, never
  `git add -A`. (On 09-24 parallel sessions in one checkout swept up each other's
  files, and Dropbox's case-insensitive sync turned `_TEMPLATE.md` vs `_template.md`
  into a "(Case Conflict)" copy.) Use lowercase file names.

**webR**
- Every webR cell sits after the first chunk's `source("_course.R")`, and no cell
  needs `#| echo: true`. The pass-through engine handles both.
- webR has no system `tar`: use `untar(..., tar = "internal")`.
- The page must not show a webR cell that depends on a slow setup without saying so:
  the first run of a mirt page takes ~20–30 s. Say this in the Simulate section.
- Two small scripts, included for every lesson by `lessons/_metadata.yml`, fix
  quarto-webr problems on pages that also carry OJS widgets (#13):
  `widgets/amd-dispatch.html` routes the global `define` so Observable's module
  loader can't capture the code editor's modules (without it the editor failed to
  initialise on ~3 of 5 loads), and `widgets/webr-run-guard.html` replays a Run
  click that lands before the editor exists. Keep both unless quarto-webr fixes
  this upstream.

**Widgets and quizzes**
- Widget math goes in `lessons/widgets/irt.js` (shared, pure functions). Add new
  helpers there rather than inline in a lesson.
- Simulated samples in widgets use the seeded `rng(seed)` from `irt.js`, so the
  picture doesn't jump around on reload and changes only when a slider moves.
- Math inside OJS `md` template strings is **not** typeset: use words there. Text
  passed to `quiz()` and `predict()` may use `$...$`; those components call MathJax.
- Check every number a quiz or predict-then-check states against the widget or the
  real-data output (the pilots' "about 75%" and "around 2" were checked by running
  the widget code in node and R).

**Data and citations**
- Citations come from IRW biblio (`get_citation` via the IRW MCP server, or the
  table's landing page), never from memory: two of the pilots' first-draft citations
  were wrong (`gilbert_meta_1` is Gilbert 2023, and the Mach IV responses are Hunter,
  Gerbing & Boster 1982, not the instrument's authors).
- Read the table's processing notes (`get_processing_notes`) before using it:
  `gilbert_meta_9` turned out to have waves, and its only script was a prefix match.
- Check keying before item analysis and FA: the Mach IV arrives unkeyed and the
  BFI-2 arrives keyed, and neither says so in its metadata.
- **Not built yet:** the generated Data sources block, and a reuse check in
  `check_tables.R` (flag any table in more than one lesson). Both are #12.

**Render and publish**
- The first render of a lesson fetches data; a transient network error can fail it
  (`Error in scan()`). Re-run; once it succeeds, `freeze` keeps the result.
- Publishing: a manual publish workflow now exists (`.github/workflows/publish.yml`,
  the Run workflow button). Local `quarto publish gh-pages --no-prompt --no-render`
  also works. §7's "Publishing is manual" should name both.

## §9 Review checklist: additions

**Mechanics**
- [ ] `python3 tools/check_page.py <page URL> "<regex only the cell's output can
      match>"` passes on the local preview and on the live site (run it a few times:
      the #13 failures were intermittent). It clicks Run once webR is Ready, waits for the output, and
      saves a screenshot for the visual check.
- [ ] Every widget changes its output when each control moves; seeded samples are
      stable on reload.
- [ ] Quiz and predict text containing math is typeset (no raw `$`).
- [ ] Downloaded `code/<id>-sim.R` and `code/<id>-irw.R` run unchanged in local R and
      give the numbers the page shows.

**Data**
- [ ] Processing notes read for every table; keying and waves checked.
- [ ] No table appears in another lesson unless the reuse is a recorded thread.
