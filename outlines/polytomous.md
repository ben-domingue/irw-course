<!-- Outlined 2026-09-24 from EDUC 252 slides c8 (slides 3–30) and c9 (slides 1–11), PS8#1–3, and the code c8/basic_polytomous_analysis.R, c9/polyexample.R, ps8/ratingscale.R, ps8/polytomous_estimates.R, ps8/polydif.R. -->

# Models for polytomous responses (`polytomous`)

Module: irt · Prereqs: information · Core · Status: outline

## Core ideas

1. **What a polytomous response is.** Likert categories, partial credit, scored constructed responses; every response must end in ordered, mutually exclusive categories. More information per item, harder to model, and expensive to score when a rater is involved. *(major)* Sources: Ostini & Nering (2006), *Polytomous item response theory models*, doi:10.4135/9781412985413.
2. **Category response functions come from dichotomizing.** Each model splits $x$ into binary questions differently: cumulative ($x > k$: the graded response model), adjacent categories ($x = k$ given $x \in \{k-1, k\}$: the (generalized) partial credit model), or sequential ($x > k$ given $x \ge k$). Then a 2PL or Rasch model is applied to each split. *(major)* Sources: Samejima (1969), doi:10.1007/bf03372160; Masters (1982), doi:10.1007/bf02296272; Muraki (1992), doi:10.1177/014662169201600206; Tutz (1990), doi:10.1111/j.2044-8317.1990.tb00925.x.
3. **CRFs and the expected response function.** The CRF gives Pr($x = k$); the ERF is the expected score, the curve most readers want. GRM thresholds must be ordered; PCM step parameters need not be, and "disordered" steps mean something different from what they seem. *(major)*
4. **The partial credit model is a Rasch model.** Sum-score sufficiency and specific objectivity carry over; the rating scale model adds a common set of thresholds across items. Sources: Masters (1982); Andrich (1978), doi:10.1007/bf02293814.
5. **What to remember.** Models with similar numbers of parameters fit similarly; the choice matters less than the choice to use the categories at all. Collapsing categories throws information away. (Ben's c9 slide 11, in his words: "Given that you won't remember all the details, here is what to remember".)

References checked on Crossref (09-24).

## Picks up

- The 2PL, slopes and thresholds (from `1pl-to-4pl`).
- Ordinal factor analysis is the normal-ogive GRM (from `fa-confirmatory`, its Go deeper).
- Sufficiency and specific objectivity (threads from `rasch`).
- Item and test information (from `information`).
- Likert responses in the IRW's ordinal coding (from `irw-data`, the Mini-IPIP).
- Reverse keying (thread from `ctt-reliability`).
- Polychorics; fit of competing models (from `fa-exploratory`, `fit-prediction`; not prerequisites, so restate).

## Promises / leaves open

- DIF for polytomous items (PS8#3) → `dif`.
- IRTrees: splitting a response into a tree (c8 slides 31–42) → `irtrees`.
- Nominal responses and unfolding (c9 slides 13–16) → `unfolding`, `nominal`.
- Constructed responses and raters: a cross-reference back to `g-theory`, which isn't a prerequisite.
- Information from polytomous items for short forms and CAT → `item-banks-cat`.
- Does the choice among GRM, GPCM and sequential models ever matter? Mostly unpaid; a candidate IMV comparison (Domingue et al., 2024).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `promis1wave1_pain` | main example | PROMIS pain item bank (Cella et al., 2010, doi:10.1016/j.jclinepi.2010.04.011): 15,961 people, 168 items, 1–5, sparse by design (each person answered a subset). The 10 most-answered items give 1,090 complete cases. GRM fits best (AIC 20,767 vs. GPCM 20,895, sequential 20,858, PCM 21,448). Slopes are large (2.5–4.3 for most items; PAINQU41 0.76). About 41% of responses are "1" (no pain), so information sits above the mean. Dichotomizing at ≥2 keeps the information near θ = 0 but loses almost all of it above: at θ = 1, 22.1 vs. 2.4. | — |
| `science_ltm` | contrast | Euro-Barometer 38.1 attitudes to science and technology (Reif & Melich, 1995, doi:10.3886/icpsr06045; the `ltm` example data, Rizopoulos, 2006, doi:10.18637/jss.v017.i05): 392 people, 7 items, 4 categories. GRM, GPCM and sequential models fit almost identically (AIC 6,050, 6,061, 6,048); the PCM (6,106) and the rating scale model (6,196) trail. Item-rest correlations are low (0.14–0.33) because the seven items form two nearly uncorrelated clusters: Work, Future, Benefit and Comfort vs. Industry, Technology and Environment (polychoric EFA, factor correlation 0.03). The model comparison holds, but the lesson should fit each cluster separately or say plainly that a one-dimensional model is a simplification here; a thread to `dimensionality`. | — |

`ffm_CSN` (PS8#1, the rating scale problem) has no tokenless CSV and waits on #15; `science_ltm` carries the rating scale comparison in its place.

## Widget / simulation / problem ideas

**Widgets**
- Three dichotomizations: a 0–3 response vector, highlighted as each model splits it (idea 2; c8 slides 10–19).
- CRF and ERF explorer: GRM and GPCM side by side, with sliders for slope and thresholds; watch the ERF barely move while the CRFs differ (ideas 3, 5).
- Adjacent-category curves: Pr($x=k$ | $x \in \{k-1,k\}$) under the PCM (clean ogives) and under the GRM (bounded, not ogives) (c8 slides 22–24).
- Information: polytomous vs. dichotomized at each cut (idea 5).

**Predict-then-check:** will the GRM, GPCM and sequential model disagree much on the PROMIS pain items? Answered by the AIC table and overlaid CRFs.

**Simulate:** generate data from the PCM; fit the PCM and the GRM; compare CRFs (PS8#2). Then dichotomize and compare information.

**Problems**
1. Derivation: show that the PCM's adjacent-category probabilities are Rasch ogives, and that the sum score is sufficient under the PCM.
2. Real data with a twist (PS8#1): fit the rating scale model and the PCM to `science_ltm`; what does the rating scale model assume, and does the data support it?
3. Judgment: for the pain items, would you report scores from the GRM or the GPCM? Does the choice change anyone's score much?
4. Design (PS8#3): simulate DIF in one threshold of one PCM item; which dichotomization makes it visible?
5. Simulation (PS8#2): find PCM parameters for which the GRM fits badly.
6. Challenge (open): the pain data pile up at "no pain". Is a floor like that a problem for the model, the population, or neither?

## Go deeper

- **The PCM is a Rasch model.** Factor the likelihood to show the sum score is sufficient; connect to `rasch`'s sufficiency callout. Why: `rasch`, `irtrees`, `item-banks-cat`. Length: half a page.
- **Information for a polytomous item.** $I(\theta) = $ variance of the score given θ (for the PCM); why polytomous items carry more information. Why: `information`, `item-banks-cat`. Length: half a page.

## Open questions

- PROMIS item text: the item ids (PAININ, PAINBE, PAINQU) map to PROMIS pain interference, behaviour and quality items. PROMIS item wording is licensed by HealthMeasures, so check reuse for #63 before quoting it.
- `science_ltm` is two nearly uncorrelated clusters, not one scale (factor correlation 0.03). Keep it as the contrast (fitting the four-item cluster alone, and using the split as a thread to `dimensionality`), or swap it for a unidimensional 4-category table?
- Should the rating scale model get its own subsection, or live only in problem 2?
