# Protocol decisions (running record)

Decisions made with Ben while writing the lesson-plan protocol. PROTOCOL.md is
written from this once every topic is settled. Still to discuss: quizzes, lesson
length, section anatomy, voice rules, vignette links, mechanics and checklist.

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

