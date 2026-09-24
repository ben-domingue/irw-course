<!-- Outlined 2026-09-24 from EDUC 252 slides c8 (slides 3–30) and c9 (slides 1–11), PS8#1–3, and the code c8/basic_polytomous_analysis.R, c9/polyexample.R, ps8/ratingscale.R, ps8/polytomous_estimates.R, ps8/polydif.R. Tidied 09-24 (#62): Ben's answers applied (B, C19, E1, A5); pick-ups checked against the drafted `rasch`. -->

# Models for polytomous responses (`polytomous`)

Module: irt · Prereqs: information · Core · Status: outline

## Core ideas

1. **What a polytomous response is.** Likert categories, partial credit, scored constructed responses; every response must end in ordered, mutually exclusive categories. More information per item; harder to model; costly to score when a rater is involved. *(major)* Source: Ostini & Nering (2006), doi:10.4135/9781412985413.
2. **Category response functions come from dichotomizing.** Each model splits $x$ into binary questions differently: cumulative ($x \ge k$: the graded response model), adjacent categories ($x = k$ given $x \in \{k-1, k\}$: the (generalized) partial credit model), or sequential ($x \ge k$ given $x \ge k-1$). Then a 2PL or Rasch model is applied to each split. *(major)* Sources: Samejima (1969), doi:10.1007/bf03372160; Masters (1982), doi:10.1007/bf02296272; Muraki (1992), doi:10.1177/014662169201600206; Tutz (1990), doi:10.1111/j.2044-8317.1990.tb00925.x.
3. **CRFs and the expected response function.** The CRF gives Pr($x = k$); the ERF is the expected score, the curve most readers want. GRM thresholds must be ordered; PCM step parameters need not be, and "disordered" steps mean something different from what they seem. *(major)* Sources: Samejima (1969); Andrich (2013), doi:10.1177/0013164412450877 (what disordered thresholds do and don't mean).
4. **The partial credit model is a Rasch model.** Sum-score sufficiency and specific objectivity carry over, which pays off `rasch`'s promise for ordered categories; the rating scale model adds a common set of thresholds across items (problem 2 only). Sources: Masters (1982); Andrich (1978), doi:10.1007/bf02293814.
5. **What to remember.** Models with similar numbers of parameters fit similarly; the choice matters less than the choice to use the categories at all. Collapsing categories throws information away. (Ben's c9 slide 11: "Given that you won't remember all the details, here is what to remember".) Sources: the PROMIS and `science_ltm` comparisons below; MacCallum, Zhang, Preacher & Rucker (2002), doi:10.1037/1082-989X.7.1.19 (the cost of dichotomizing).

DOIs Crossref-checked 09-24.

**Verdict (voice rule A):** GRM or GPCM for the pain items, verdict first ("it rarely matters; use the categories").

## Picks up

- The 2PL, slopes and thresholds (from `1pl-to-4pl`).
- Sufficiency and specific objectivity; the promise that they carry over to ordered categories (threads from `rasch`).
- Item and test information; $1/\sqrt{I}$ (from `information`).
- Likert responses in the IRW's ordinal coding (from `irw-data`, the Mini-IPIP).
- Reverse keying (thread from `ctt-reliability`).
- Ordinal factor analysis is the normal-ogive GRM (from `fa-confirmatory`, not an ancestor; E2: one "if you've done it" sentence).
- Polychorics; fit of competing models (from `fa-exploratory`, `fit-prediction`; not ancestors, E2: restated in a sentence each).

## Promises / leaves open

- IRTrees: splitting a response into a tree (c8 slides 31–42) → `irtrees`.
- Unfolding (ideal-point responses) → `unfolding`; nominal responses (c9 slides 13–16) → `nominal`.
- Information from polytomous items for short forms and CAT; the PCM is a Rasch model → `item-banks-cat`.
- Constructed responses and raters: a pointer back to `g-theory`, which isn't an ancestor (E2).
- Ordinal DIF: `dif` no longer depends on this lesson (Ben, 09-24, E1); `dif` has a problem on ordinal DIF (the CES-D). A pointer only, no hook.
- `science_ltm`'s two clusters: several dimensions are `dimensionality`'s subject. A pointer, not a thread (this lesson isn't an ancestor of `dimensionality`; E2).
- Does the choice among GRM, GPCM and sequential models ever matter across the IRW? Unpaid; a candidate IMV comparison (Domingue et al., 2024, doi:10.1007/s11336-024-09977-2).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `promis1wave1_pain` | main example | PROMIS pain item bank (Cella et al., 2010, doi:10.1016/j.jclinepi.2010.04.011): 15,961 respondents, 168 items, 1–5, sparse by design (each respondent answered a subset). The 10 most-answered items give 1,090 complete cases. GRM fits best (AIC 20,767 vs. GPCM 20,895, sequential 20,858, PCM 21,448). Slopes are large (2.5–4.3 for most items; PAINQU41 0.76). 41% of responses are "1" (no pain), so information sits above the mean. Dichotomizing at ≥2 keeps it near θ = 0 and loses almost all of it above (at θ = 1: 22.1 vs. 2.4). | — |
| `science_ltm` | contrast | Euro-Barometer 38.1 attitudes to science and technology (Reif & Melich, 1995, doi:10.3886/icpsr06045; the `ltm` example data, Rizopoulos, 2006, doi:10.18637/jss.v017.i05): 392 respondents, 7 items, 4 categories. The seven items form two nearly uncorrelated clusters (polychoric EFA, factor correlation 0.03): Work, Future, Benefit and Comfort vs. Industry, Technology and Environment. On all seven, GRM, GPCM and sequential models fit almost identically (AIC 6,050, 6,061, 6,048), with the PCM (6,106) and the rating scale model (6,196) behind. The lesson fits the four-item cluster and says why. | — |

**Decisions (Ben, 09-24):**
- `science_ltm` stays as the contrast; the lesson fits the four-item cluster (Work, Future, Benefit, Comfort), with the split as a pointer to `dimensionality` (C19). The AIC numbers above are for all seven items; the four-item fits are computed at drafting.
- The rating scale model lives in problem 2 only (C19).
- PROMIS item wording is licensed by HealthMeasures: the lesson summarizes the items (interference, behaviour, quality) and cites them, and quotes none (A5).
- `ffm_CSN` (PS8#1) has no tokenless CSV and no subsample (A4).

## Widget / simulation / problem ideas

**Widgets**
- Three dichotomizations: a 0–3 response vector, highlighted as each model splits it (idea 2; c8 slides 10–19).
- CRF and ERF explorer: GRM and GPCM side by side, with sliders for slope and thresholds; the ERF barely moves while the CRFs differ (ideas 3, 5).
- Adjacent-category curves: Pr($x=k$ | $x \in \{k-1,k\}$) under the PCM (clean ogives) and under the GRM (not ogives) (idea 4; c8 slides 22–24).
- Information: polytomous vs. dichotomized at each cut (idea 5).

**Predict-then-check:** will the GRM, GPCM and sequential model disagree much on the PROMIS pain items? Answered by the AIC table and overlaid CRFs.

**Simulate:** data from the PCM; fit the PCM and the GRM; compare CRFs (PS8#2). Then dichotomize and compare information.

**Problems**
1. Derivation: show that the PCM's adjacent-category probabilities are Rasch ogives, and that the sum score is sufficient under the PCM.
2. Real data with a twist (PS8#1): fit the rating scale model and the PCM to the four-item `science_ltm` cluster; what does the rating scale model assume, and do the data support it?
3. Judgment: for the pain items, would you report scores from the GRM or the GPCM? Does the choice change anyone's score much?
4. Design: for a new survey item, would you offer three, five or seven categories, and what would you check in pilot data (disordered steps, empty categories, information)?
5. Simulation (PS8#2): find PCM parameters for which the GRM fits badly.
6. Challenge (open): the pain data pile up at "no pain". Is a floor like that a problem for the model, the population, or neither?

## Go deeper

- **The PCM is a Rasch model.** Factor the likelihood to show the sum score is sufficient. Why: `irtrees`, `item-banks-cat`. Length: half a page.
- **Information for a polytomous item.** $I(\theta)$ = the variance of the score given θ (for the PCM); why polytomous items carry more information. Why: `item-banks-cat`, `nominal`. Length: half a page.

## Open questions

- None.
