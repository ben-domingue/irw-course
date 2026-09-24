<!-- Outlined 2026-09-24. New material (not in EDUC 252); from the landscape analysis (notes/landscape-2026-09-24.md, gap 2), which also folds interrater reliability in here. -->

# Many sources of error: generalizability theory (`g-theory`)

Module: ctt · Prereqs: instrument-building · Core · Status: outline

## Core ideas

1. **CTT has one error term; the world has many.** Tasks, raters, occasions: each is a facet, and each contributes error. *(major)*
2. **Variance components.** A persons × tasks × raters design decomposes score variance into persons, facets and their interactions; estimate them with a random-effects model. *(major)*
3. **G coefficients.** Relative (rank-ordering) and absolute (level) decisions use different error terms; the generalizability coefficient reduces to alpha in the one-facet case.
4. **D studies.** With the components in hand, ask what happens with more tasks or more raters. The answer depends on which components are large. *(major)*
5. **Interrater reliability as a special case.** Agreement vs. consistency; ICCs as G coefficients.

## Picks up

- $X = T + E$, reliability, SEM, alpha, Spearman–Brown (from `ctt-reliability`).
- Raters and constructed-response scoring (from `instrument-building`, if taught first; not a prerequisite).
- Reliability is a property of scores in a population (from `ctt-reliability`).
- Blueprints and domain sampling: items as a facet (from `constructs`).

## Promises / leaves open

- Raters as a facet in item response models → unpaid (rater models, many-facet Rasch); flag for the Beyond module.
- Random-effects models for item responses → `explanatory-irt` (items and persons as random effects).
- Occasions as a facet → `invariance-experience`; ESM data otherwise unpaid.
- Absolute error for decisions against a cut score → `score-meaning`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `Forthmann-2024-cleverness_ratings` | main example | 202 people, 3 alternate-uses tasks, 5 raters, fully crossed. Persons 32% of variance, person × task 29%, residual 30%; raters small (rater 2%, person × rater 6%). So a D study says: add tasks, not raters. | — |
| `teacherjudgements_lohmann_2026_essayratings` | contrast | 881 essays, 4 criteria, 316 raters (sparse). Here raters matter: rater 14%, essay × rater 19%, against essays 28%. More raters per essay is the lever. | — |

## Widget / simulation / problem ideas

**Widgets**
- Variance pie: sliders for each component; the G coefficient for relative and absolute decisions updates (ideas 2, 3).
- D-study planner: number of tasks and raters; G coefficient as a surface, for each table's components (idea 4).
- Consistency vs. agreement: two raters, one harsher by a constant; ICC(consistency) stays high, ICC(agreement) drops (idea 5).

**Predict-then-check:** for the cleverness ratings, which will be the larger source of error, the raters or the tasks? Answered by the variance components.

**Simulate:** a persons × tasks × raters design with known components; estimate them with `lme4` (a few seconds in webR?) and compare with the truth; vary the number of raters.

**Problems**
1. Derivation: show that the one-facet (persons × items) G coefficient for relative decisions equals alpha.
2. Real data with a twist: from the cleverness components, how many tasks and raters give a relative G of 0.8? Is there more than one answer?
3. Judgment: the essay table is sparse (each essay has few raters). What does that do to the estimates, and to your D study?
4. Design: plan a G study for a performance assessment you know: facets, crossing, sample sizes.
5. Real data: compute consistency and agreement ICCs for two raters in the cleverness data.
6. Challenge (open): G theory treats raters as exchangeable. When is a harsh rater a different kind of error from an inconsistent one, and what model would you use?

## Go deeper

- **Expected mean squares for the p × i design.** How the variance components are identified from an ANOVA table, and why the G coefficient equals alpha. Why: `ctt-reliability`, `score-meaning`. Length: half a page.

## Open questions

- New material, not in 252: are variance components by `lme4` the right tool for a first course, or classic ANOVA (EMS) tables?
- `lme4` is in the webR binary repository (repo.r-wasm.org, version 2.0-1 for R 4.5), so it loads. Timing gets checked when the lesson is drafted; if it's slow, Simulate uses precomputed results plus downloadable code.
- Interrater reliability is folded in here (per the landscape analysis). Enough, or does it need its own section?
