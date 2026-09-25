<!-- Outlined 2026-09-24. New material (not in EDUC 252); from the landscape analysis (notes/landscape-2026-09-24.md, gap 2), which also folds interrater reliability in here. Tidied 09-24 (#62): C8 default applied (lme4 now, EMS as Go deeper) while #76 is pending; citations added and verified. -->

# Many sources of error: generalizability theory (`g-theory`)

Module: ctt · Prereqs: instrument-building · Core · Status: draft (09-25, #57)

## Core ideas

References verified 09-24 against Crossref unless noted; table citations from IRW biblio. Plan per digest C8: variance components from a random-effects model (`lme4`; Bates, Mächler, Bolker & Walker, 2015, *Journal of Statistical Software* 67(1), doi:10.18637/jss.v067.i01), with the ANOVA/EMS route as the Go deeper. Revisit when #76 answers.

1. **CTT has one error term; the world has many.** *(major)* Tasks, raters, occasions: each is a facet, and each contributes error (Cronbach, Rajaratnam & Gleser, 1963, *British Journal of Statistical Psychology* 16(2), 137–163, doi:10.1111/j.2044-8317.1963.tb00206.x; Cronbach, Gleser, Nanda & Rajaratnam, 1972, *The Dependability of Behavioral Measurements*, Wiley, no DOI, verified via Bock's 1972 review in *Science*, doi:10.1126/science.178.4067.1275).
2. **Variance components.** *(major)* A persons × tasks × raters design splits score variance into persons, facets and their interactions; estimate them with a random-effects model (Brennan, 2001, *Generalizability Theory*, Springer, doi:10.1007/978-1-4757-3456-0; Shavelson & Webb, 1991, *Generalizability Theory: A Primer*, Sage, no DOI, verified via Sundre's 1993 review, doi:10.1177/109821409301400219).
3. **G coefficients.** Relative (rank-ordering) and absolute (level) decisions use different error terms; the relative G coefficient for a persons × items design is alpha (Brennan, 2001). A short overview for readers: Shavelson, Webb & Rowley (1989, *American Psychologist* 44(6), 922–932, doi:10.1037/0003-066X.44.6.922).
4. **D studies.** *(major)* With the components in hand, ask what happens with more tasks or more raters. The answer depends on which components are large.
5. **Interrater reliability as a special case.** Consistency vs. agreement; ICCs as G coefficients (Shrout & Fleiss, 1979, *Psychological Bulletin* 86(2), 420–428, doi:10.1037/0033-2909.86.2.420; McGraw & Wong, 1996, *Psychological Methods* 1(1), 30–46, doi:10.1037/1082-989X.1.1.30). One subsection, not a separate lesson (landscape analysis).

## Picks up

- $X = T + E$, reliability, SEM, alpha, Spearman–Brown (from `ctt-reliability`).
- Many sources of error at once; reliability is a property of scores in a population (from `ctt-reliability`).
- Raters and constructed-response scoring (from `instrument-building`).
- Blueprints and domain sampling: items as a facet (from `constructs`).

## Promises / leaves open

- Random-effects models for item responses → `explanatory-irt` (items and persons as random effects).
- Absolute error for decisions against a cut score → `score-meaning` (not a descendant: an "if you've done `g-theory`" Recall there, per E2).
- Occasions as a facet → `invariance-experience` (a Recall, per E2); ESM data otherwise unpaid.
- Raters as a facet in item response models → unpaid (rater models, many-facet Rasch); flagged for the Beyond module.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `Forthmann-2024-cleverness_ratings` | main example | Cleverness ratings of alternate-uses responses (Forthmann & Myszkowski, 2024, "Analysis of a divergent thinking dataset", OSF, https://osf.io/a9qnc; CC BY 4.0; no DOI). 202 respondents, 3 tasks, 5 raters, fully crossed. Persons 32% of variance, person × task 29%, residual 30%; raters small (rater 2%, person × rater 6%). So a D study says: add tasks, not raters. | — |
| `teacherjudgements_lohmann_2026_essayratings` | contrast | Teachers rating student essays (Lohmann et al., 2026, *Journal of Educational Psychology* 118(6), 941–960, doi:10.1037/edu0000969; CC BY 4.0). 881 essays, 4 criteria, 316 raters (sparse). Here raters matter: rater 14%, essay × rater 19%, against essays 28%. More raters per essay is the lever. | — |

Numbers from the 09-24 outline pass (not recomputed). **Recomputed in the draft (09-25):** cleverness as above (person 32.1%, person × task 29.4%, residual 29.6%, rater 2.1%, person × rater 5.5%). Essays, with the expert-benchmark rows removed (315 teachers, 5 essays each; 435 of 881 essays have one teacher): essay 29.7%, rater 9.7%, essay × rater 25.2%, essay × criterion 9.6%. The rater and essay × rater shares differ from the outline's (14%, 19%), but the conclusion (more raters is the lever) stands. Sanity: the simulation (known components recovered) checks the `lme4` pipeline before the real tables.

## Widget / simulation / problem ideas

**Widgets**
- Variance pie: sliders for each component; the G coefficient for relative and absolute decisions updates (ideas 2, 3).
- D-study planner: number of tasks and raters; G coefficient as a surface, for each table's components (idea 4).
- Consistency vs. agreement: two raters, one harsher by a constant; ICC(consistency) stays high, ICC(agreement) drops (idea 5).

**Predict-then-check:** for the cleverness ratings, which will be the larger source of error, the raters or the tasks? Answered by the variance components.

**Simulate:** a persons × tasks × raters design with known components; estimate them with `lme4` and compare with the truth; vary the number of raters. `lme4` is in the webR repository (2.0-1 for R 4.5); if the fit is slow in the browser, Simulate shows precomputed results with downloadable code.

**Problems**
1. Derivation: show that the one-facet (persons × items) G coefficient for relative decisions equals alpha.
2. Real data with a twist: from the cleverness components, how many tasks and raters give a relative G of 0.8? Is there more than one answer?
3. Judgment: the essay table is sparse (each essay has few raters). What does that do to the estimates, and to your D study?
4. Design: plan a G study for a performance assessment you know: facets, crossing, sample sizes.
5. Real data: compute consistency and agreement ICCs for two raters in the cleverness data.
6. Challenge (open): G theory treats raters as exchangeable. When is a harsh rater a different kind of error from an inconsistent one, and what model would you use?

## Go deeper

- **Expected mean squares for the p × i design.** How the variance components are identified from an ANOVA table, and why the G coefficient equals alpha (Brennan, 2001). Why: `ctt-reliability`, `score-meaning`; the classic route beside the `lme4` main line (C8). Length: half a page.

## Open questions

- **#76 (questions for colleagues) is pending.** Is `lme4` the right main tool for a first course, or should the classic ANOVA/EMS tables lead? *Default:* `lme4` in the main line, EMS as the Go deeper (C8); revise when #76 answers.

## Drafting notes (09-25)

- Drafted on the #76 default: `lme4` main line; EMS/ANOVA as a Go deeper, with the one-facet ANOVA, `lme4` and alpha compared numerically on the cleverness task means in *With real data*.
- `lme4` runs in webR (2.0-1): the Simulate fit (1,350 rows, seven components) takes about 2 s in the browser, so nothing is precomputed. The essay fit (about 25 s in local R) runs only at render.
- Widgets: variance components by role (ideas 2–3), D study with lines by raters (idea 4), consistency vs. agreement (idea 5). The "D-study surface" became lines by number of raters; the per-table D study is an R figure in *With real data*, so the predict-then-check is not spoiled.
- The D study in the essays treats the four criteria as a random facet; fixed facets and nested D-study designs are named, not developed.
- Pointers only: many-facet Rasch (Going further, Eckes 2011), random item effects (`explanatory-irt`), error at a cut (`score-meaning`), occasions (`invariance-experience`).
- **Revision after Ben's review (09-25, PR #147):** Ben asked for a widget showing how the two G coefficients differ. The first widget ("where the variance goes") became "the two coefficients side by side", placed where Eρ² and Φ are introduced: sliders for all seven components and n_t, n_r, starting at the cleverness estimates with an essay preset; one stacked bar per coefficient, with the absolute-only pieces (task, rater, task × rater) in a distinct colour. It feeds the D-study widget, so the count stays at 3. Because the widget now shows the cleverness components, the predict-then-check moved from "tasks or raters?" to the D study (6 tasks × 1 rater vs. 3 × 5), just before the output that answers it.
