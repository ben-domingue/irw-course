# Open questions: digest for Ben

**Parts 1 and 2 (2026-09-24).** Part 1 (sections A–C) covers the cross-cutting
decisions and the 23 outlines on main (Foundations, CTT, factor analysis, IRT,
competitions). Part 2 (sections E and F, plus additions to B and D) covers Validity,
Fairness, Using calibrated items and Beyond from main and the outline branches below.

Part 2 read these versions (refreshed after PR #92 merged):
- main at `c98c0d2`, which now includes the Beyond part 2 outlines (PR #92, merged at
  `349f48f`): response-time, rt-process-models, trials, ai-psychometrics;
- `8-outlines-validity` at `9bc8435` (PR #94): validity-argument, validity-causal,
  validity-evidence, dif, invariance-experience;
- `8-outlines-beyond-1` at `e1fd007` (no PR yet): explanatory-irt (cdm, irtrees,
  unfolding and nominal not yet outlined there);
- `8-outlines-uses` at `24389f1` (PR #96): score-meaning, equating, item-banks-cat,
  scale-properties (added after part 2 merged; questions E10–E12, F14–F25);
- #62 and the open `needs-ben` issues as of 2026-09-24 19:30.

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

**Answered (Ben, 09-24): yes, and use "respondent".** Recorded in `notes/notation.md`.

**A4. Teaching subsamples (#15).** ENEM, ffm and PISA have no tokenless CSV. The outlines
found alternatives: RMET for `1pl-to-4pl`, dropped for `dimensionality`, pending for
`irtrees`. The Using-calibrated-items session is trying TIMSS for `equating`.
*Default:* publish only an **ENEM 2013 LC subsample with booklets intact**. It's the
one dataset whose design (forms sharing items) the alternatives can't easily match,
for `equating`, with `1pl-to-4pl` guessing as a bonus. ffm and PISA are nice-to-have,
not needed.

**Answered (Ben, 09-24):** if `equating` needs ENEM, store a subsample in the course
repo (`lessons/data/`, with provenance), not as a new IRW table. `1pl-to-4pl` and the
other lessons don't use ENEM. No ffm or PISA subsamples.

**A5. Item text (#63).** *Default:*
- Snapshot item text into the repo with a provenance manifest: source, fetch date, and
  an id↔text alignment check against the original.
- Show full text on the public site only for public-domain or openly licensed
  instruments (likely IPIP, DASS, Grit for non-commercial use, NAEP descriptors; Claude confirms each licence). For
  everything else, give summaries plus a citation.
- Longer term, the IRW adds tokenless item-text CSVs.

**Answered (Ben, 09-24): ok.**

**A6. Competition-table access (`competitions`).** Competition tables have no IRW
landing page, so there's no tokenless CSV. *Default:* publish teaching copies as standard
IRW tables, with landing pages, the same route as A4. Until then the lesson stays a
stub.

**A7. How lessons read data (`irw-data`).** *Default:* lessons read the tokenless CSV
(`irw_csv()` in `_course.R`); `irw::irw_fetch` appears in *Going further* for readers
with a Redivis login.

**Answered (Ben, 09-24): ok.**

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

Part 2 (from #62, #45, #65, #15 and PR #92):
- `rapm_poulton_2022_untimed` is a fourth table in `response-time` (timed vs. untimed
  Raven's).
- Deep dive #25: a language-model feature in `compute.R` is punted; the corpus run
  uses word count and mean word length.
- Table reuse is fine where it serves a thread; use tables broadly where possible
  (the recording question is E4).
- The reliability paradox: `validity-evidence` pays the `ctt-reliability` hook briefly;
  `trials` gives the full treatment; `validity-causal` uses its Stroop table for
  Borsboom's between/within point. No formal thread.
- IL-HTE lives in `invariance-experience` (optional); `dif` introduces it (#45).
  PS7#1 is homed there; `explanatory-irt` only points to it.
- `rt-process-models` is its own optional lesson after `response-time` (#65).
- No PISA subsample (#15, A4), so `response-time` uses `credentialform_lnirt`; there's
  nothing to revisit.
- Sanity tables aren't listed in lessons.yml, so they don't count as reuses.
- Deep dive #25 lives in `ai-psychometrics` (agreed by the two Beyond sessions).
- `equating` uses TIMSS 2011, not ENEM. ENEM is available as a repo subsample (A4),
  but it isn't needed.
- Cut scores: `score-meaning` takes them as decisions (norms, error near the cut,
  classification consistency); `validity-evidence` takes classification accuracy
  against a criterion (agreed by the two sessions).

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
  optional third table if A4 happens. **Answered (Ben, 09-24): RMET; no ENEM here.**
- **C12 `ability-estimation`**: plausible values in one paragraph here, or in
  `score-meaning`? *Default:* one paragraph here; the full treatment in `score-meaning`.
- **C13 `information`**: the contrast table is a schizotypy screening scale.
  *Default:* keep it; it makes the targeting point sharply. Its framing is gentle,
  about where the test is aimed, not about the people.
- **C14 `item-estimation`**: the real-data prior check is null (at most 0.02).
  *Default:* keep it as a reassuring check; the dramatic case goes in Simulate.
  Conditional ML gets a sentence (optional lesson).
- **C15 `guessing-priors`**: which paper backs "the 3PL doesn't really work" (c6
  slide 61)? **Answered:** Domingue, Kanopka, Kapoor, Pohl, Chalmers, Rahal &
  Rhemtulla (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2.
  §3 and the Table 1 discussion: IMV(2PL, 3PL) never exceeds 0.001, even when the 3PL
  generates the data. They cite 3PL identification problems (Maris & Bechger, 2009;
  Haberman, 2005; von Davier, 2009).
- **C16 `fit-prediction`**: the IMV is your work. How much first person? And what is
  the source of the 89-dataset IMV comparison (c6 slide 21)? **Answered:** the same
  paper, §4 ("The IMV in Empirical Data"): 89 dichotomous IRW datasets. Related: the
  IMV in PLOS ONE (Domingue et al., 2025, doi:10.1371/journal.pone.0316491) and for
  CFA with binary outcomes (Zhang et al., 2026, *Multivariate Behavioral Research*,
  doi:10.1080/00273171.2026.2645212), which suits `fa-confirmatory` and `sem`. *Default:* first person where you give a verdict, per A1.
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

---

## E. Part 2: cross-cutting questions

**E1. Prerequisite changes.** Several outlines lean on lessons that aren't their
ancestors, and `check_course()`'s thread check only accepts ancestors. Each line says
what adding the prerequisite costs. *Defaults:*
- `dif ← fa-confirmatory, polytomous`: **add both.** `dif` teaches multigroup CFA and
  polytomous DIF. Both already come before `dif` in the first-course path, so nothing
  moves.
- `validity-argument ← ctt-reliability`: **add.** The lesson recalls alpha
  ("reliability is necessary, not sufficient"). `ctt-reliability` already comes first
  in both paths.
- `validity-evidence ← instrument-building`: **add.** Content evidence starts at item
  writing. `instrument-building` already comes before it in the first-course path.
- `rt-process-models ← 1pl-to-4pl`: **add.** Idea 3 maps the diffusion model onto
  the 2PL. `1pl-to-4pl` is core, so readers of an optional Beyond lesson will have it.
- `response-time ← guessing-priors`: **don't add.** Restate the one finding it needs
  in a paragraph instead (3.1% of `roar_lexical` responses come in under 0.3 s, at 0.51
  accuracy). Adding it would put `ability-estimation`, `fit-prediction`
  and `guessing-priors` (two of them optional) in front of `response-time`, only for
  one Recall.
- `ai-psychometrics ← explanatory-irt`: **add.** Both are optional and in the same
  module. `explanatory-irt` teaches the LLTM and was written to hand deep dive #25
  ("can text alone predict difficulty?") on to this lesson. The cost: readers reach
  `ai-psychometrics` through `rasch → explanatory-irt` as well as `1pl-to-4pl`.

**E2. Hooks from lessons that aren't ancestors.** Examples: `invariance-experience`
recalls `g-theory` (occasions) and `fa-exploratory` (randomized formats); `dif` recalls
`instrument-building`, `parameter-invariance`, `sem` and `validity-evidence`;
`validity-causal` answers a hook from `sem`. *Default:* allow brief "if you've done X"
Recalls, with no formal thread (threads need an ancestor, PROTOCOL §4). Consequence:
these connections won't appear in the header box.

**E3. `validity-evidence` and the factor-analysis module.** `fa-confirmatory` hands
"bifactor models: one construct or three?" to `validity-evidence`, which comes before
both FA lessons in the first-course path. *Default:* keep the order. `fa-confirmatory`
answers its own question (its DASS example already has omega hierarchical) and drops
the hook; `validity-evidence` notes internal structure briefly and points forward.
Moving `validity-evidence` after the FA module would split the Validity module around
FA in the path.

**E4. Deliberate table reuses.** You said on 09-24 that reuse is fine where it serves
a thread. These are the reuses in the outlines; check_tables.R wants each recorded
under `reuses:` on the later lesson. The first three are already recorded on main
(PR #92); the last two aren't:
- `rr98_accuracy`: `irw-data` → `trials`;
- `roar_lexical`: `guessing-priors` → `response-time` (rapid guessing);
- `credentialform_lnirt`: `response-time` → `rt-process-models` (the failure case for
  the diffusion model);
- `verbagg`: `irw-data` → `explanatory-irt` (described there, modelled here; recorded
  on the unmerged `8-outlines-beyond-1` branch);
- `wilmer-rmet-normative-data-set-2022`: `1pl-to-4pl` → `nominal`. It's on main but not
  recorded, and check_tables.R flags it today.

*Default:* keep the three already recorded and record the other two. Don't add `bfi2_zhang_2025` (randomized response formats)
to `invariance-experience`: a Recall of `fa-exploratory`'s finding is enough.
Consequence: check_tables.R's remaining reuse failure (RMET) clears once lessons.yml
records it.

**E5. Data the lessons want that the IRW doesn't have.** You marked this "to discuss"
(PR #92). The gaps:
- NBA shot data (Samangy, GitHub) and LEVANTE mental rotation with angle and RT
  (`trials`);
- per-question language-model benchmark results, and essays with both human and
  machine scores (`ai-psychometrics`);
- item-level HRS CES-D data for the spousal-loss example (`invariance-experience`);
- balance-scale responses (`validity-causal`).

*Default:* add nothing now. Each lesson runs on its stand-in table or on simulation, as
the outlines plan (`mentalrotation_wolf_2024`, oREV, a cited figure for spousal loss,
widgets for automated scoring). Revisit after drafting, when it's clear which gap hurts
most. Consequence: none of these lessons waits on new data.

**E6. When a table's source licence and its IRW page differ.** Example:
`ieswriting_molloy_2022` is CC BY-NC-SA 4.0 at the source (ETS on GitHub) but CC BY 4.0
on its IRW page. *Default:* follow the stricter licence (the source). A free course
fits NC-SA; quote a few items with citation rather than showing the whole survey.
Claude flags each mismatch to the IRW (D). Consequence: A5's "openly licensed" test
uses the source licence.

**E7. Showing AI-written items in full (`ai-psychometrics`).** You asked for this in
plainer words (PR #92). Two of the lesson's tables are items written by ChatGPT or
GPT-4o, released by their authors as CC BY 4.0 (`gpt4mcq_young_2025`) and CC0
(`genpsych_russell_2024_gpt4o`). Under A5 we show full text only for openly licensed
instruments. Should we show these items in full, like any other openly licensed
instrument? *Default:* yes, citing the authors and naming the model that wrote them.
Consequence: `ai-psychometrics` can show all its items.

**E8. First-person verdicts the slides don't give.** Like A2, these need your writing:
- `validity-causal`: your view of Borsboom's definition: a replacement for the argument
  view, a complement, or a concept for a different grain size of test? Slide 15 ends
  with worries, not a verdict. *Your answer needed*: the lesson's verdict has to be
  yours.
- `response-time` (in plainer words, as you asked in PR #92): on c9 slide 29 you wrote
  "I don't much like this model" about van der Linden's speed–accuracy model. Its
  weak spot is that it assumes each person works at one constant speed throughout the
  test. Should that objection be the lesson's first-person verdict? The data support
  it: how accuracy changes when a person is slower than usual differs across the
  lesson's three tables. *Default:* yes, in your words from the slide plus one
  sentence of reason.

**E9. The EM conversation for `item-estimation` (#38).** A claude.ai chat that Claude
Code can't read. *Your answer needed*: paste the useful parts into #38, or say to go
ahead without them. Only you can open it.

**E10. Prerequisites for Using calibrated items.** *Defaults:*
- `score-meaning ← information`: **add.** The conditional SEM then comes from a Recall
  instead of being re-taught; `information` is core. `ability-estimation` stays a
  pick-up without a prerequisite.
- `item-banks-cat ← ability-estimation, polytomous`: **add both.** Since PR #90,
  `ability-estimation` no longer comes before `information`, so EAP isn't upstream, and
  the PROMIS contrast is graded. Both are core, so the optional lesson doesn't re-teach
  EAP or the GRM.

**E11. The split between `measurement` and `scale-properties` (#66).** *Default:*
- `measurement` keeps the levels of measurement, the claim that an interval scale needs
  an equal unit, one RCT rescaling demonstration and the stochastic-dominance callout,
  with no IRT.
- `scale-properties` takes conjoint measurement, what the Rasch model licenses
  (conditional on fit; the 2PL's metric is a convention), gains, growth, vertical
  scales and gap trends.
- `measurement`'s hook "unpaid for growth and vertical scales unless `equating` takes
  it" becomes "→ `score-meaning`, `equating`, `scale-properties`". `equating` names
  vertical scaling and points to `scale-properties`.

Consequence: a core reader still meets the interval question in `measurement` and
`score-meaning`.

**E12. Precomputed results outside deep dives.** `item-banks-cat`'s post-hoc CAT (600
respondents × five rules) takes about 19 minutes locally. *Default:* precompute it the
way deep dives are (a `compute.R` and a committed `.rds`), and run a 50-respondent
version live in the page. Consequence: the compute/render split in PROTOCOL §5 extends
beyond deep dives.

---

## F. Part 2: per-lesson questions (defaults are safe to accept in bulk)

**Validity**
- **F1 `validity-argument`**: Simulate in a conceptual lesson. The proposal is a
  contaminated-criterion simulation: the AUC rises as the "diagnosis" borrows from the
  screener's items. Keep it, or record a §10 exception? *Default:* keep it. It's the
  lesson's real-data finding in miniature.
- **F2 `validity-argument`**: the main example's ADHD flag is the DSM rule applied to
  the same items (AUC 0.99 by construction). It's framed as a fact about a study built
  for network analysis, not a flaw. *Default:* keep that framing.
- **F3 `validity-argument`**: carry your slide-16 disclosure (you worked with two of
  the four approved dyslexia screeners) into problem 5? *Default:* yes, in one clause.
- **F4 `validity-causal`**: no balance-scale data in the IRW. Is oREV (age of
  acquisition predicts Rasch difficulty, r = 0.80) a fair stand-in for a theory of
  response behaviour? *Default:* yes. The balance scale stays as the worked example in
  prose and widgets.
- **F5 `validity-causal`**: cite Kelley's "measures what it purports to measure" as
  quoted in Borsboom et al. (2004)? *Default:* yes, unless Claude finds the Kelley page
  (D).
- **F6 `validity-evidence`**: classification accuracy needs a fourth table, and the
  MTMM already uses two (self and colleague HEXACO). *Default:* teach it with the ROC
  widget, the simulation and a Recall of the ADHD table from `validity-argument`. The
  IRW has no screener with an independent diagnosis (searched 09-24).
- **F7 `validity-evidence`**: correct SAT–GPA to the national SAT SD, or keep the
  within-sample range-restriction demonstration (top half on SAT: r 0.43 → 0.25,
  corrected 0.34)? *Default:* within-sample only. It needs no outside figure.

**Fairness**
- **F8 `dif`**: the slides' DART table. A checked foil name scores 1, like a
  recognized author, and there are 199 respondents. *Default:* drop it from the tables;
  keep the Austen/Allende vs. Clancy/Krabbé pattern as a problem with the foils
  removed.
- **F9 `dif`**: the main example's biggest finding is treatment DIF (`gilbert_meta_11`:
  every demographic grouping essentially category A; treatment 3 C items), which is
  `invariance-experience`'s subject. *Default:* lead with it, per the #44 scope note.
  `invariance-experience` uses different tables.
- **F10 `invariance-experience`**: deep dive #26 takes the first post-randomization
  wave per table rather than "wave 1" (`gilbert_meta_20` codes its pretest 0;
  `gilbert_meta_74` has waves 1 and 2). *Default:* adopt it, and suggest the same fix
  for the IRW IL-HTE vignette in an IRW issue.

**Using calibrated items**
- **F14 `score-meaning`**: how much standard setting? *Default:* one core idea and an
  Angoff widget; the bookmark method named only; no separate lesson.
- **F15 `score-meaning`**: a clinical screener (PHQ-9) as the main example rather than
  an achievement test. *Default:* keep the PHQ-9. It has real norms, a real cut and two
  waves, and no tokenless achievement table has norms and a published cut.
- **F16 `score-meaning`**: the norm contrast (a German pre-pandemic sample against a UK
  spring-2020 panel) mixes country, year, language and mode. *Default:* use it as a
  lesson about reference groups, saying plainly that the gap can't be put down to the
  pandemic.
- **F17 `equating`**: TIMSS 2011 (`cdm_timss11`, a 14-booklet common-item ring with
  randomly equivalent groups) instead of ENEM. *Default:* TIMSS. ENEM's booklets are the
  same items reordered, and no items are shared across years.
- **F18 `equating`**: the position effect (the booklet ring fails to close by 1.1
  logits) as the predict-then-check. *Default:* keep it; it pays off c6 slide 47.
- **F19 `equating`**: PIRLS across four countries as the nonequivalent-groups contrast
  edges into DIF and alignment. *Default:* keep it, with a pointer to `dif`.
- **F20 `equating`**: scope. *Default:* equating and IRT linking in full; vertical
  scaling named (growth goes to `scale-properties`); concordance (e.g. SAT–ACT) in one
  sentence.
- **F21 `item-banks-cat`**: c10 slides 45–46 point to "state summative data in IRW
  format" for building a bank. *Your answer needed*: only you know which data set the
  slides mean.
- **F22 `item-banks-cat`**: PROMIS depression as the contrast, read as a question of
  bank design (where the items are), not about the respondents. *Default:* keep it.
- **F23 `scale-properties`**: the known-answer check is a Rasch-simulated copy of the
  main table, not an IRW table. *Default:* accept it as the sanity check.
- **F24 `scale-properties`**: your own papers (Domingue, 2014; Briggs & Domingue, 2013)
  are central sources. *Default:* cite them as ordinary literature.

**Beyond**
- **F11 `explanatory-irt`**: `lme4` throughout instead of `mirt`. *Default:* yes. The
  LLTM and random items are mixed models, and `lme4` is what the IL-HTE and trials
  lessons use too. Webr speed is Claude's check (D).
- **F12 `rt-process-models`**: problem 2 needs a word/nonword flag for
  `mturkddm_lexical`, which the tokenless CSV lacks. *Default:* take it from the
  item-text snapshot (A5).
- **F13 `ai-psychometrics`**: the automated-scoring section has no table (see E5).
  *Default:* widget-only.

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

Part 2:
- Verify or replace: Messick (1989), Kelley (1927) (page for the "purports to measure"
  line), Thorndike (1949), Camilli (2006), the exact wording and page of Borsboom et
  al.'s (2004) definition, the item-level figure in the supplement of Domingue et al.
  (2021), the IEEE essay-scoring meta-analysis (c10 slide 7, IEEE 11062635),
  Stenner et al. (2006), and the source of "r = 0.62, Embretson & Daniel" (c10
  slide 25). Ask Ben only for any that stay unfound.
- Find slide sources: the secondary text quoting Dorans & Kulick on DECOY : DUCK (c5
  slide 13), the JD-Next predictive-bias figure (c5 slide 24), and the CDE original of
  the CAASPP purposes (c3 slide 21; only a district copy found).
- Data checks: `gilbert_meta_11` grade (the IRW says grade 1); `alexandrowicz_2018_cesd`
  sex coding against the paper's data file; rescore HEXACO with the published key; check
  whether `gilbert_meta_37`'s night-blindness items match the programme's content
  (Carpena, 2024); `motion`'s second item index (processing notes); the TROG testlet
  fit.
- webR checks: `lme4` (`explanatory-irt`, `g-theory`) and `rtdists`
  (`rt-process-models`; fall back to a plain random walk).
- Licence checks (A5, E6): `ieswriting_molloy_2022` (flag the mismatch to the IRW), the
  oREV picture materials, whether the Forecasting Proficiency Test's general-knowledge
  items were adapted from older pools, and instrument reuse for the `gilbert_meta`
  outcomes.
- Using calibrated items: verify Angoff (1971), Lord & Novick (1968), the bookmark
  method (Lewis et al.), Reckase (1983), Sympson & Hetter (1985), Karabatsos (2001) and
  Asparouhov & Muthén (2014); check Shevlin et al.'s (2020) wave-1 prevalence of
  PHQ-9 ≥ 10 against our 22%; read what Choi et al. (2010) found for PROMIS CAT vs.
  short forms; read the Project KIDS wave timing and treatments on LDbase before the
  lesson describes the programme; check the PHQ-9's reuse terms against A5; read the
  processing notes for the seven Uses tables.
