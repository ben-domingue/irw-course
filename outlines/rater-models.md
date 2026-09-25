<!-- Outlined 2026-09-25. New extension lesson, added by Ben while reviewing g-theory ("we should have an advanced page on rater models"); an explicit exception to the frozen lesson list. No EDUC 252 source. Pays g-theory's hook on raters as a facet in item response models. -->

# Rater models: many-facet Rasch and beyond (`rater-models`)

Module: beyond · Prereqs: g-theory, rasch · Extension · Status: outline

## Core ideas

References verified 09-25 against Crossref; table citations from IRW biblio (`lessons/_citations.yml`).

1. **G theory asks how much raters matter; a rater model asks which rater, and by how much.** *(major)* In `g-theory` raters are exchangeable, summarized by a variance component. When scores go to individuals, a harsh rater is a bias in one respondent's score, not only noise. Opens on g-theory's problem 6. Sources: Sudweeks, Reeve & Bradshaw (2004), doi:10.1016/j.asw.2004.11.001 (both approaches on the same ratings); Briggs & Wilson (2007), doi:10.1111/j.1745-3984.2007.00031.x (G theory as an item response model).
2. **The many-facet Rasch model.** *(major)* Add a rater term to the Rasch logit: log-odds of category k over k−1 = θ_j − b_i − ρ_r − τ_k, with ρ_r the rater's severity. Raters join persons and items on the Wright map, and a respondent's measure is adjusted for the raters they drew, provided the design links the raters. Sources: Linacre (1989), *Many-Facet Rasch Measurement*, MESA Press (no DOI; verified in the Crossref reference lists of Engelhard 1994 and Eckes 2005); Eckes (2011), doi:10.3726/978-3-653-04844-5; Andrich (1978), doi:10.1007/BF02293814 (the step τ_k); applications: Engelhard (1994), doi:10.1111/j.1745-3984.1994.tb00436.x; Eckes (2005), doi:10.1207/s15434311laq0203_2.
3. **Beyond severity: centrality and halo.** Centrality squeezes ratings toward the middle (rater-specific thresholds); halo makes distinct criteria move together more than the performance does. Each is a question the data can answer, not a charge against a rater. Sources: Thorndike (1920), doi:10.1037/h0071663; Saal, Downey & Lahey (1980), doi:10.1037/0033-2909.88.2.413.
4. **The hierarchical rater model: raters rate the response, not the respondent.** *(major)* Many-facet Rasch treats each rating as a locally independent observation of θ, so more raters shrink the standard error as if they were more items. The hierarchical rater model puts an ideal rating of each response between respondent and raters: IRT for the ideal rating, a signal-detection model (severity, precision) for each rater. More raters pin down the response, not the respondent. Sources: Patz, Junker, Johnson & Mariano (2002), *JEBS* 27(4), 341–384, doi:10.3102/10769986027004341; DeCarlo, Kim & Johnson (2011), doi:10.1111/j.1745-3984.2011.00143.x; the rater bundle model, Wilson & Hoskens (2001), doi:10.3102/10769986026003283.
5. **Raters change, and raters are many: drift and random effects.** Severity can move within a session or across years; add time to the rater term and test it (Myford & Wolfe, 2009, doi:10.1111/j.1745-3984.2009.00088.x). With hundreds of raters rating a handful each, severities become random effects: G theory's rater component again, now inside an item response model (De Boeck, 2008, doi:10.1007/s11336-008-9092-x; `lme4`, doi:10.18637/jss.v067.i01). Going further: rater-specific discrimination (Uto & Ueno, 2020, doi:10.1007/s41237-020-00115-7).

## Picks up

- Facets, variance components, consistency vs. agreement; raters as exchangeable; problem 6 on harsh vs. inconsistent raters (from `g-theory`).
- The cleverness and essay tables and their variance components (from `g-theory`; deliberate reuses).
- The Rasch model, one logit scale, the Wright map, infit and outfit, sufficiency (from `rasch`).
- The rating-scale model, restated in a paragraph (if you've done `polytomous`, E2; see Open questions).
- Raters as random effects in `glmer` (if you've done `explanatory-irt`, E2).

## Promises / leaves open

- Automated scorers as one more rater, with severity and centrality → unpaid (the AI lesson isn't downstream; a pointer, E2).
- Drift on real timestamps → unpaid (neither table has rating dates).
- Rater × criterion interactions (differential rater functioning, a DIF analogue) and rater-specific discrimination → unpaid (Going further).
- Choosing among many-facet Rasch, the hierarchical rater model and crossed random effects by out-of-sample prediction → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `Forthmann-2024-cleverness_ratings` | main example | 202 respondents × 3 tasks × 5 raters, fully crossed, 1–5. Many-facet Rasch severities run from −0.32 to 0.37 logits (SD 0.29, SE 0.04–0.08) against a person SD of 1.20: raters differ reliably but modestly, g-theory's "rater 2%" one rater at a time. | `g-theory` (reuse recorded) |
| `teacherjudgements_lohmann_2026_essayratings` | contrast | 881 essays, 4 criteria, 1–7; 315 teachers rate 5 essays each, and an expert benchmark rates every essay. Teacher SD 0.69 points against essay SD 1.14 (residual 1.03); leniency spans −0.7 to +0.8 points (10th–90th percentile). Teachers average 0.3 below the benchmark and correlate 0.40 with it. Criteria correlate 0.66 within teachers' ratings, 0.45 within the benchmark's: the halo question the source study asks (Lohmann et al., 2026). Centrality doesn't show: 152 of 315 teachers spread less than the benchmark on the same essays. | `g-theory` (reuse recorded) |

How the numbers were computed (09-25, tokenless CSVs; recompute in `lessons/code/rater-models-irw.R`):
- cleverness: reshape to one row per respondent × rater, one column per task, then `TAM::tam.mml.mfr(resp, facets = w["rater"], pid = w$id, formulaA = ~ item + rater + item:step)`.
- essays: drop `expert_benchmark` rows, then `lme4::lmer(resp ~ item + (1 | id) + (1 | rater))`; halo and centrality from criterion correlation matrices and per-teacher SDs, each set against the benchmark on the same essays.
- The same `TAM` fit failed on the essay table (variance step; 315 sparse raters), which motivates idea 5.

Data notes, stated gently: `expert_benchmark` is 3,524 of the essay table's 9,824 rows, and the lesson separates it from the teachers; how the benchmark was built is to be read in the source before drafting. Sanity: the simulation's known severities, recovered by `TAM`.

## Widget / simulation / problem ideas

**Widgets**
- One harsh rater: raw means and many-facet measures diverge only for respondents who drew that rater (ideas 1, 2).
- Wright map with a rater column (idea 2).
- A central rater: shrink the outer thresholds; ratings pile up in the middle while the mean stays put (idea 3).
- More raters, same essay: SE of θ under many-facet Rasch against the hierarchical rater model (idea 4).

**Predict-then-check:** will criteria correlate more strongly within a teacher's ratings or within the benchmark's? Answered by the two correlation matrices.

**Simulate:** 200 respondents × 3 tasks × 5 raters with known severities (one harsh, one central); fit many-facet Rasch in `TAM`; compare with the truth; then give each respondent two raters and see what linking needs. Whether `TAM` runs in webR is to be checked; otherwise precomputed, with downloadable code.

**Problems**
1. Derivation: show that the sum score is sufficient for θ given the raters' severities, and why raw sums of respondents who drew different raters aren't comparable.
2. Real data with a twist: estimate severities in the cleverness data by task. Is a harsh rater harsh everywhere?
3. Judgment: an essay scored by one harsh teacher. Report the raw rating, the adjusted measure, or get a second rating?
4. Design: 1,000 essays, 20 raters, two ratings each. Assign raters so severities are estimable (linking networks).
5. Real data: does teacher leniency relate to the rater covariates (experience, semester)?
6. Challenge (open): halo, or a common quality the analytic criteria split artificially? What design would tell them apart?

## Go deeper

- **Why many-facet Rasch over-counts raters.** Under local independence information grows linearly in the number of raters; under the hierarchical rater model it is bounded by one ideal rating. Why: idea 4 (extension; not a depth-pass candidate). Length: half a page.

## Open questions

- **Prerequisite on `polytomous`.** Both tables are ordered categories and the model is a rating-scale model with a rater term. *Default:* add `polytomous` (core, so the tranche rule holds) at the next between-wave pass; until then one restating paragraph.
- **A third table for drift.** `moralvignettes_rakhmankulova_2025` and `thomeczek2025_les` carry `date` and `rater`, but their raters rate vignettes and parties. *Default:* no third table; drift by widget and simulation, those tables in Going further.
- **Hierarchical rater model software.** `sirt::rm.hrm` fits it (not yet tried here). *Default:* main line `TAM` and `lme4`; the hierarchical rater model on the simulation and the cleverness table only.
- **First-person verdict.** *Default:* on problem 3's choice: when scores go to individuals and raters differ reliably, adjust for severity and say so in the report.
