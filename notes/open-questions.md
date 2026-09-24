# Open questions: digest for Ben

**Part 1 of 2 (2026-09-24).** Covers the cross-cutting decisions and the 23 outlines on
main (Foundations, CTT, factor analysis, IRT, competitions). Part 2 adds Validity,
Fairness, Using calibrated items and Beyond when their outline PRs land.

**How to answer:** every question has a recommended default. Reply "defaults except
A2, C7" (or similar) and give your answer for the exceptions. Claude then records
each answer in the outline, the issue and #62. Section D is Claude's own work, listed
so you can see it is handled.

---

## A. Cross-cutting decisions (these shape many lessons; worth real attention)

**A1. Voice rules (#3).** The audit (`notes/voice-audit-2026-09-24.md`) proposes six
rules:
- A: one first-person verdict per lesson;
- B: graded adverbs, no enthusiasm words;
- C: question pivots, no "Here is a fact that…";
- D: no coy verdicts;
- E: state the baseline for size words;
- F: no softeners, at most one "worth ___ing".

You've accepted the rewrites that came from them, but not the rules themselves.
*Default:* adopt all six as written; revise if drafts show a problem.
**Answered (Ben, 09-24): all six adopted.**

**A2. Your two verdicts (#3).** These are the only items here that need your writing,
not a yes/no:
- Equal slopes, at the hidden TODO in `lessons/rasch.qmd`.
- Would you report alpha? Would you rely on it? At the hidden TODO in
  `lessons/ctt-reliability.qmd`.

*Default:* none; a sentence or two each in your words, or dictate them and Claude
drafts.

**A3. Notation (new; nothing is fixed yet).** Several sessions will draft in parallel,
so fix these now in `notes/notation.md`. *Defaults:*
- Ability $\theta$; difficulty $b$; slope $a$, called "discrimination" in prose;
  lower asymptote $c$; upper asymptote $u$. Using $u$ avoids a clash with `mirt`'s
  intercept $d$.
- Formulas use the slope–difficulty form $a(\theta - b)$ on the logistic metric, with no
  $D$. $D \approx 1.7$ appears only in the Camilli aside (`rasch`) and in the
  FA↔IRT conversion (`fa-confirmatory`).
- `mirt`'s intercept form $a\theta + d$ appears only in code, with $b = -d/a$ stated
  wherever the code converts.
- "Item-rest correlation" (corrected), not item-total, unless the point is the
  inflation.
- Responses are coded so that higher = more of the construct, and each lesson states
  its keying once.
- "Respondent" or "person", not "examinee" (many tables aren't tests). "Item" throughout;
  "probe" only in `measurement`.

**A4. Teaching subsamples (#15).** ENEM, ffm and PISA have no tokenless CSV. The outlines
found alternatives: RMET for `1pl-to-4pl`, dropped for `dimensionality`, pending for
`irtrees`. The Using-calibrated-items session is trying TIMSS for `equating`.
*Default:* publish only an **ENEM 2013 LC subsample with booklets intact**. It's the
one dataset whose design (forms sharing items) the alternatives can't easily match,
for `equating`, with `1pl-to-4pl` guessing as a bonus. ffm and PISA are nice-to-have,
not needed.

**A5. Item text (#63).** *Default:*
- Snapshot item text into the repo with a provenance manifest: source, fetch date, and
  an id↔text alignment check against the original.
- Show full text on the public site only for public-domain or openly licensed
  instruments (likely IPIP, DASS, Grit for non-commercial use, NAEP descriptors; Claude confirms each licence). For
  everything else, give summaries plus a citation.
- Longer term, the IRW adds tokenless item-text CSVs.

**A6. Competition-table access (`competitions`).** Competition tables have no IRW
landing page, so there's no tokenless CSV. *Default:* publish teaching copies as standard
IRW tables, with landing pages, the same route as A4. Until then the lesson stays a
stub.

**A7. How lessons read data (`irw-data`).** *Default:* lessons read the tokenless CSV
(`irw_csv()` in `_course.R`); `irw::irw_fetch` appears in *Going further* for readers
with a Redivis login.

---

## B. Settled today (for the record; no action)

- IRT order: `rasch → 1pl-to-4pl → information → ability-estimation`. This answers the
  `information` question about 2PL information.
- Prerequisites: `dimensionality ← fa-confirmatory`, `polytomous ← information`,
  `fa-exploratory ← instrument-building`, `g-theory ← instrument-building`.
- `sem` is optional (#64). The constructs slide-11 verdict and sources are confirmed.
  `andrich_mudfold` is a thread into `unfolding`.
- Grit keying: higher = more grit. The perseverance items are reversed, per the IRW
  option text.

---

## C. Per-lesson questions (defaults are safe to accept in bulk)

**Foundations**
- **C1 `measurement`**: rescaling (order-preserving transformations change a treatment
  effect) as the real-data hook for a conceptual lesson? *Default:* yes.
- **C2 `measurement`**: add Bond & Lang (2013) on fragile test-score gaps (not in 252)?
  *Default:* yes, once the citation is verified (D).
- **C3 `likelihood`**: the predict-then-check turns on non-collapsibility (the Elo slope
  rises from 0.50 to 0.83 when items get intercepts). Too subtle for lesson three?
  *Default:* keep it, with one sentence saying it isn't confounding.

**Classical test theory**
- **C4 `constructs`**: Simulate compares a continuum with latent classes. *Default:*
  keep it.
- **C5 `ctt-limits`**: the page is mostly the PS2#4 "guided tour" simulation. *Default:*
  keep it in the main line; it's the lesson's argument.
- **C6 `ctt-reliability`**: problem 6 ("alpha at scale") overlaps deep dive #20.
  *Default:* keep the problem as the small version and point to the deep dive.
- **C7 `instrument-building`**: no natural Simulate section; the proposal is a
  wording-factor simulation. *Default:* accept.
- **C8 `g-theory`**: see #76 (questions for colleagues). *Default:* wait for their
  answers; meanwhile plan `lme4`, with EMS tables as a Go deeper.

**Factor analysis**
- **C9 `fa-confirmatory`**: `lavaan` syntax first appears here rather than in `sem`.
  *Default:* yes.
- **C10 `fa-confirmatory`**: its prerequisite `1pl-to-4pl` puts it after the first IRT
  lessons, though it sits in the FA module. *Default:* keep. The IRT-as-FA idea needs
  the 2PL.

**Item response theory**
- **C11 `1pl-to-4pl`**: RMET (easy; guessing median 0.05) now, or wait for ENEM?
  *Default:* RMET now. The weak guessing is itself a finding, and ENEM stays as an
  optional third table if A4 happens.
- **C12 `ability-estimation`**: plausible values in one paragraph here, or in
  `score-meaning`? *Default:* one paragraph here; the full treatment in `score-meaning`.
- **C13 `information`**: the contrast table is a schizotypy screening scale.
  *Default:* keep it; it makes the targeting point sharply. Its framing is gentle,
  about where the test is aimed, not about the people.
- **C14 `item-estimation`**: the real-data prior check is null (at most 0.02).
  *Default:* keep it as a reassuring check; the dramatic case goes in Simulate.
  Conditional ML gets a sentence (optional lesson).
- **C15 `guessing-priors`**: which paper backs "the 3PL doesn't really work" (c6
  slide 61)? *Your answer needed* (or: drop the citation and keep the argument
  data-driven).
- **C16 `fit-prediction`**: the IMV is your work. How much first person? And what is
  the source of the 89-dataset IMV comparison (c6 slide 21)? *Your answer needed*
  for the source. *Default:* first person where you give a verdict, per A1.
- **C17 `parameter-invariance`**: keep the selection effect (splitting on the same
  items' sum score breaks the 2PL)? *Default:* keep it, a real and teachable finding.
  Leave forms to `equating`.
- **C18 `dimensionality`**: qgrit11 loads −0.37 after keying (your PS6 flagged it too).
  *Default:* the lesson notes it gently as an item worth reading.
- **C19 `polytomous`**: `science_ltm` is two nearly uncorrelated clusters. *Default:*
  keep it and fit the four-item cluster, with the split as a thread to `dimensionality`.
  The rating scale model lives in problem 2 only.

**Competitions** (optional)
- **C20**: home in Beyond (optional), or in IRT next to Rasch? *Default:* Beyond,
  optional.
- **C21**: main example NBA (small, clean) or lichess (continues the chess thread;
  needs a subsample)? *Default:* NBA now, lichess if A6 produces a subsample.

---

## D. Claude's to-do (no action from Ben)

- Verify or replace: Bond & Lang (2013); Baker & Kim (2004); Baker (2001) edition and
  figure; Lusardi & Mitchell (2014); Han (2012); Wright & Masters (1982); Wu & Adams
  (2013); Thurstone (1947).
- Check: RSES item-text alignment against the original (`song_2023_rses`,
  `bakker_2020_rses`); whether the Florida twins data carry a family id; whether
  `lme4` runs in webR fast enough (`g-theory`).
- Add baselines: "wide spread of difficulty" (`rasch`, diffsim vignette) and
  "unusually clean" (`fa-exploratory`, dimensionality vignette).
- Tidy #62: #5 and #13 are done; the #3 baselines are Claude's, not Ben's.
