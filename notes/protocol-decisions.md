# Protocol decisions (running record)

Decisions made with Ben while writing the lesson-plan protocol. PROTOCOL.md is
written from this once every topic is settled. Still to discuss: voice rules,
vignette links, mechanics and checklist.

## Audience, tables, problems, solutions, proofs (2026-09-24)
- **Audience:** Claude drafting lessons.
- **Tables:** at most **3** IRW tables per lesson, each with a stated job
  (main example / contrast / failure case) given in one sentence where it is introduced.
- **Problems:** **6** per lesson (mix: derivation; real data with a twist;
  judgment; design; challenge, possibly open).
- **Solutions:** held back, in a **gitignored `solutions/`** folder in this repo,
  `solutions/<id>.qmd`, one worked solution per problem; open problems get a
  "what we know so far" note.
- **Proofs:** in collapsible callouts, out of the main line (the alpha proof is
  the model).
- **`ctt_failures` (PS2#4)** stays in `ctt-limits` ("Where CTT breaks"), linked back to
  the alpha lower-bound proof as a thread (how loose the bound can be).

## Decided: outline first, then cross-check (Ben, 09-24)
Lessons must be in conversation. Rather than pre-specifying threads, **outline every
lesson** (all 35, optional included; the pilots are outlined backwards from their
pages) in `outlines/<id>.md` with fixed headings: Core ideas · Picks up · Promises /
leaves open (hooks) · Tables (≤3, with jobs) · Widget / simulation / problem ideas.
(plus **Go deeper**, below). Then run **iterative cross-check passes**: every hook paid off or flagged unpaid;
every pick-up introduced earlier; duplication and gaps. One report per pass; Ben
reviews module by module; repeat until clean. The agreed result is then recorded as
threads (below), which the build checks.

## Decided: depth components (Ben, 09-24)
Some lessons go deep on a key result, in a collapsible callout (the alpha proof is
the model). **Criterion: load-bearing, not merely elegant**: go deep where many later
lessons pick the idea up.
- Outline template gets a **Go deeper** field: candidate derivations/proofs (the
  result, why it matters, rough length).
- Cross-checks add a **depth pass**: rank candidates by how many lessons pick them up;
  propose a short list; Ben cuts.
- Protocol: always collapsible, never in the main line; self-contained with stated
  assumptions; 0–2 per lesson.
- First agreed target: **sufficiency** in `rasch` (factorize the likelihood so it
  depends on θ only through r; conditioning on r removes θ, which gives conditional ML
  and makes specific objectivity a theorem; converse per Andersen: sufficiency ⇒ Rasch).
- Likely candidates: parallel forms ⇒ reliability (ctt-reliability); Rasch item
  information = p(1−p) (information); EM (item-estimation); ordinal FA ≡ 2PL/GRM
  (fa-confirmatory); no MLE for perfect patterns (ability-estimation).

## Threads (the record the cross-checks produce)
An idea introduced in one lesson (e.g. specific objectivity) is shown violated or
extended later. Recorded as:

- `lessons.yml` gets a `threads:` list: `id`, `idea`, `introduced` (lesson),
  `returns` (list of `{lesson, how}`).
- The lesson header box shows "Starts threads" / "Picks up threads" with links.
- `check_course()` fails on unknown lessons in threads, and on a thread that returns
  to a lesson that comes earlier than where it was introduced, by prerequisite order.
- Drafting rule: before writing a lesson, read every thread touching it; pay off each
  one it owes with a "Recall" callout linking back; register any new assumption or
  promise as a thread.

Seed threads from the pilots (inputs to the cross-checks, not final):
| Thread | Introduced | Returns in (how) |
|---|---|---|
| Specific objectivity | rasch | 1pl-to-4pl (crossing ICCs in chess data), parameter-invariance |
| Sum score is sufficient | rasch | 1pl-to-4pl (2PL weights items), ability-estimation |
| Local independence | rasch | explanatory-irt (repeated trials), dimensionality |
| Unidimensionality | rasch, fa-exploratory | dimensionality, fa-confirmatory |
| The scale has no origin | rasch | fa-exploratory (rotation, already linked), equating |
| Alpha ≤ reliability; tau-equivalence | ctt-reliability | ctt-limits (ctt_failures), fa-confirmatory (omega) |
| One SEM for everyone | ctt-reliability | information (CSEM varies), score-meaning |
| Reverse keying | ctt-reliability | fa-exploratory (already linked), polytomous |


## Data breadth and citation (2026-09-24)
- **Breadth:** draw on a broad sample of IRW tables rather than reusing the same
  few. A table appears in one lesson only, unless the reuse is deliberate (a thread
  returning to the same data) and recorded. `check_tables.R` will flag reuse (#12).
- **Citation:** every table used is cited, linked where possible (DOI/URL from IRW
  biblio via `get_citation`, never from memory), with a link to its IRW landing
  page. A generated **Data sources** block closes each lesson (#12).

## Deep dives (2026-09-24, detail open in #4)
A few lessons go deep with IRW data at corpus scale: a miniature on one table, then
the precomputed corpus result with code, then a pointer to the vignette. Nine
candidates are issues #18–#26 (milestone 4). Proposed: deep dives are an exception
to the 3-table ceiling.

## Quizzes (2026-09-24, #1)
- **Quick checks:** 2–4 per lesson, all in *Core ideas*, one after each major
  subsection (not every subsection). None in *With real data* or *Problems*.
- **Predict-then-check:** exactly **one required**, placed in *With real data*
  immediately before the output that answers it, and about the finding that section
  turns up (the model is fa-exploratory: BFI-2, parallel analysis says 9 against a
  5-domain design). At most one extra predict in *Core ideas*, tied to a widget
  (e.g. the rasch Wright map).
- Pilots to conform: ctt-reliability's Mach IV predict moves into *With real data*
  (just before the unkeyed alpha); rasch needs a real-data predict (e.g. which
  chess item misfits) and keeps the Wright-map one as its optional extra.
- Components: `quiz()` and `predict()` in `lessons/widgets/quiz.js`.

## Lesson length and section anatomy (2026-09-24, #2)
- **Section order (fixed, all required):** header box · What this is for · Goals ·
  Core ideas (Try it widgets, quick checks, collapsible depth) · Simulate · With real
  data · Problems · Ask Claude (generated by `_course.R`) · Going further · For
  instructors. `check_course()` can enforce the H2 sequence.
- **Caveat:** if a section seems not to fit a lesson (e.g. Simulate in a conceptual
  lesson), don't drop it silently. Raise it with Ben, and record any agreed
  exception here.
- **Length:** one lesson is one class session's worth. Target **2,000–3,000 words
  of prose**, excluding code and collapsibles (the pilots run 2,200–2,650). Word count
  replaces rendered height (12,000–20,000 px) as the measure.
- **Over length:** move material into collapsibles or *Going further* first.
  Splitting a lesson is a curriculum change, decided at the outline stage, not
  while drafting.

## Tracking
Work is tracked in GitHub issues on ben-domingue/irw-course: milestones 1 Protocol,
2 Outlines & cross-checks, 3 Lessons (one issue per lesson), 4 Deep dives,
5 Infrastructure.
