<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 18–34, 60–61) and c4/enem1.R, enem3.R. -->

# From the 1PL to the 4PL (`1pl-to-4pl`)

Module: irt · Prereqs: rasch · Core · Status: outline

## Core ideas

1. **One family of curves.** $\Pr(x=1) = c + (d - c)\,\text{logit}^{-1}(a(\theta - b))$: difficulty $b$, discrimination $a$, lower asymptote $c$ (guessing), upper asymptote $d$ (slip). The Rasch model/1PL fixes $a$ (and $c=0, d=1$); the 2PL frees $a$; the 3PL frees $c$; the 4PL frees $d$. What "L" means. *(major)* Sources: Birnbaum (1968), in Lord & Novick, *Statistical theories of mental test scores* (book chapter; to verify); Lord (1980), *Applications of item response theory to practical testing problems*, doi:10.4324/9780203056615 (reprint DOI); Barton & Lord (1981), doi:10.1002/j.2333-8504.1981.tb01255.x (upper asymptote); Loken & Rulison (2010), doi:10.1348/000711009x474502 (4PL).
2. **What slopes cost: sufficiency and crossing curves.** With free slopes, the sum score is no longer sufficient (the 2PL weights items by $a$), and ICCs cross, so "item A is easier than item B" depends on who is asked. *(major)* Thread from `rasch` (specific objectivity; sufficiency) and `likelihood` (per-item Elo slopes in chess).
3. **Reading `mirt`.** The slope–intercept form $a\theta + d$ and `IRTpars = TRUE` ($b = -d/a$); identification: the Rasch model fixes slopes at 1 and centres $\theta$; the 2PL fixes $\theta \sim N(0,1)$; the "1PL" with one common estimated slope for comparison with the 2PL and 3PL. Source: Chalmers (2012), doi:10.18637/jss.v048.i06.
4. **Two philosophies.** Rasch: choose items that fit a model motivated by what measurement means. IRT: model the data's idiosyncrasies. A big philosophical distinction, and ability estimates that are highly comparable in practice. *(major)* Sources: Wright (1997), doi:10.1111/j.1745-3992.1997.tb00606.x ("Ben Wright would be furious", slide 24); Andrich (2004), doi:10.1097/01.mlr.0000103528.48582.7c (the Rasch and IRT paradigms).
5. **Beyond four: asymmetric curves.** The 5PL and logistic positive exponent models, briefly. Sources: Samejima (2000), doi:10.1007/bf02296149; Lee & Bolt (2018), doi:10.1007/s11336-017-9586-5.

Crossref-checked 09-24 unless marked. Choosing among these models by out-of-sample prediction is `fit-prediction`'s job; this lesson previews it with information criteria only.

## Picks up

- The Rasch model, ICCs, the scale has no origin, sufficiency, specific objectivity (from `rasch`).
- The slope slider in the Rasch ICC widget, and D ≈ 1.7 with Camilli (1994) (from `rasch`).
- Logistic regression; items differ in how strongly Elo predicts success (from `likelihood`).
- Item–sum curves with different steepness (from `ctt-limits`).

## Promises / leaves open

- Which model is better, and by how much → `fit-prediction` (out-of-sample prediction; IMV).
- Guessing as an item property is shaky; person-level guessing; fixing $c$; priors → `guessing-priors`.
- Information now depends on $a$ (and $c$) → `information`.
- Estimating with more parameters (EM, priors) → `item-estimation`, `guessing-priors`.
- Are the estimated parameters the same in another group? → `parameter-invariance`.
- Slopes as factor loadings → `fa-confirmatory`.
- The slip parameter returns in cognitive diagnosis → `cdm`.
- How much do slopes vary across the IRW? → deep dive #21.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `wilmer-rmet-normative-data-set-2022` | main example | Reading the Mind in the Eyes (Baron-Cohen et al., 2001, doi:10.1111/1469-7610.00715), 36 four-option items, 17,680 complete respondents (normative data from Kim et al., 2024, doi:10.3758/s13428-023-02323-x). Items are easy (p = 0.56–0.86). 2PL slopes vary about fivefold (0.21–1.2). Despite four options, 3PL lower asymptotes are mostly near zero (median 0.05; range 0–0.68): with easy items there is little information about the bottom of the curve. BIC prefers the 2PL (5,000-person sample: 205,529 vs. 1PL 206,497, 3PL 205,803, 4PL 205,961). Abilities from all four models correlate 0.97–1.00. | `parameter-invariance` uses the MRMET table from the same paper, not this one. |
| `chess_lnirt` | contrast (deliberate thread from `rasch` and `likelihood`) | 2PL slopes on the 40 chess problems run from 0.02 (Y15, the item Elo barely predicts in `likelihood`) to 3.8 (Y29, also the steepest Elo slope there); Y15's nearly flat curve crosses every other item's. | `likelihood`, `rasch` (record under `reuses:`) |

**ENEM (pending #15).** The 252 code uses `enem_2013_1mil_lc` (Brazil's national exam, 5-option multiple choice, harder items), where the 3PL's guessing parameters are more visible. It has no tokenless CSV. If a teaching subsample is released (#15), it would make a better third table for idea 1 than anything tokenless found so far.

## Widget / simulation / problem ideas

**Widgets**
- One ICC with sliders for $a$, $b$, $c$, $d$ and the Rasch curve as a ghost (idea 1).
- Two items with free slopes: where do they cross, and who finds which easier? (idea 2)
- Sum score vs. 2PL score: the same 5-item pattern set as the `rasch` sufficiency widget, with the 2PL weights shown (idea 2).

**Predict-then-check:** RMET items have four answer options. What lower asymptote will the 3PL estimate? Answered by the guessing parameters (median 0.05, not 0.25).

**Simulate:** generate 3PL data with $c = 0.25$; fit 1PL, 2PL and 3PL; compare recovered parameters and ability estimates; vary the sample size to see the 3PL wobble (the 252 slide 61 point that the Rasch model recovers abilities well even from 3PL data).

**Problems**
1. Derivation: show that under the 2PL, $\sum_i a_i x_i$ is sufficient for $\theta$, and that under the 3PL no simple statistic is.
2. Derivation: for the 3PL, at $\theta = b$ the probability is $(1+c)/2$, not 0.5. What does $b$ mean now?
3. Real data with a twist: fit the 2PL and 3PL to the RMET using only people with sum scores in the bottom quarter. Do the lower asymptotes change? Why?
4. Judgment: a colleague wants to report 3PL guessing parameters for the RMET as "the rate at which people guess". What would you tell them?
5. Real data: in the chess data, find two items whose 2PL curves cross inside the range where most players sit. For which players is each item easier?
6. Challenge (open): the 1PL, 2PL and 3PL abilities correlate above 0.97. When would the choice of model still matter for a decision about a person?

## Go deeper

- **Sufficiency under the 2PL (weighted sum score) and its loss under the 3PL.** Why: `ability-estimation`, `item-estimation`, `information`. Length: half a page. Candidate for the depth pass (#10); it extends the agreed `rasch` sufficiency callout.

## Open questions

- ENEM vs. a tokenless table (#15): the RMET is easy for most people, so it shows guessing weakly. Worth waiting for an ENEM subsample, or is the weak guessing itself the lesson?
- RMET items are photographs of eyes with four words; no item text in the IRW. Fine for a model-comparison lesson?
