<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 18–34, 60–61) and c4/enem1.R, enem3.R. Tidied 09-24 (#62): Ben's answers applied; pick-ups checked against the drafted `likelihood` and `rasch`. -->

# From the 1PL to the 4PL (`1pl-to-4pl`)

Module: irt · Prereqs: rasch · Core · Status: outline (page is a draft)

## Core ideas

1. **One family of curves.** $\Pr(x=1) = c + (u - c)\,\text{logit}^{-1}(a(\theta - b))$: difficulty $b$, discrimination $a$, lower asymptote $c$ (guessing), upper asymptote $u$ (slip), per `notes/notation.md`. The Rasch model fixes $a = 1$, $c = 0$, $u = 1$; the 2PL frees $a$; the 3PL frees $c$; the 4PL frees $u$. What the "L" counts. *(major)* Sources: Birnbaum (1968), chs. 17–20 in Lord & Novick, *Statistical theories of mental test scores* (book, no DOI; confirmed via Crossref's record of a review, doi:10.2307/2283550); Lord (1980), doi:10.4324/9780203056615; Barton & Lord (1981), doi:10.1002/j.2333-8504.1981.tb01255.x (upper asymptote); Loken & Rulison (2010), doi:10.1348/000711009x474502 (4PL).
2. **What slopes cost: sufficiency and crossing curves.** `rasch` already flips its sufficiency widget to a 2PL and drags a slope until two ICCs cross. This lesson says what replaces the sum score: under the 2PL the weighted sum $\sum_i a_i x_i$ is sufficient; under the 3PL no simple statistic is. Then it finds crossing curves in real data (chess Y15 against the rest). *(major)* Sources: Birnbaum (1968); Andersen (1977), doi:10.1007/bf02293746 (which models have sufficient statistics).
3. **Reading `mirt`, and identification.** The intercept form $a\theta + d$ appears only in code, with $b = -d/a$ stated where the code converts. The Rasch fit fixes slopes at 1 and estimates the SD of $\theta$; the 2PL fixes $\theta \sim N(0,1)$ and frees the slopes; a "1PL" with one common estimated slope is the Rasch fit rescaled. Source: Chalmers (2012), doi:10.18637/jss.v048.i06.
4. **Two philosophies.** The Rasch tradition chooses items that fit a model motivated by what measurement should mean; the IRT tradition models the data it has. The lesson asks what each assumes, and shows that on the RMET the four models' abilities correlate 0.97–1.00. *(major)* Sources: Wright (1997), doi:10.1111/j.1745-3992.1997.tb00606.x; Andrich (2004), doi:10.1097/01.mlr.0000103528.48582.7c.
5. **Beyond four: asymmetric curves.** The logistic positive exponent model, in one paragraph. Sources: Samejima (2000), doi:10.1007/bf02296149; Lee & Bolt (2018), doi:10.1007/s11336-017-9586-5.

DOIs Crossref-checked 09-24. This lesson compares models by BIC only (*whether*, not *how much*); out-of-sample comparison is `fit-prediction`'s.

**Across the IRW (deep dive #21, home here):** how much 2PL slopes vary across the IRW's tables; the [2PL vignette](https://itemresponsewarehouse.org/vignettes/2pl_across_datasets.html), which `rasch` already links. Pays off `rasch`'s "are equal slopes plausible?".

**Verdict (voice rule A):** which model to fit on a test like the RMET, verdict first (the 2PL, with BIC and the ability correlations as the rationale).

## Picks up

- The Rasch model and ICCs; the slope slider and the normal-CDF challenge ($D \approx 1.7$) in the ICC widget (from `rasch`).
- The scale has no origin; `mirt` fixes the mean ability at 0 (from `rasch`).
- Sufficiency, with the widget's 2PL switch; crossing ICCs and specific objectivity (from `rasch`).
- Per-item logistic regressions on Elo: slopes from near 0 (Y15, Y31) to about 2 (Y29); non-collapsibility (from `likelihood`).
- Item–sum curves with different steepness (from `ctt-limits`).
- Item-rest correlations as a first look at discrimination (from `irw-data`).

## Promises / leaves open

- Which model is better, and by how much → `fit-prediction` (out-of-sample prediction; IMV).
- The lower asymptote learns little on easy tests; fixing $c$; person-level guessing; priors → `guessing-priors`.
- Information now depends on $a$ and $c$ → `information`.
- Estimating with more parameters (EM, priors) → `item-estimation`, `guessing-priors`.
- Are the estimated parameters the same in another group? → `parameter-invariance`.
- Weighted scores: ability estimates under the 2PL → `ability-estimation`.
- The 2PL as the working model downstream → `fa-confirmatory` (loadings), `polytomous`, `dimensionality`, `dif`, `equating`, `item-banks-cat`, `unfolding` (negative slopes), `ai-psychometrics`, `rt-process-models`.
- RMET's weak guessing (median $c$ = 0.05 with four options) → `nominal` (distractors; deliberate reuse, E4).
- The slip parameter in cognitive diagnosis → `cdm` (not a descendant; an "if you've done it" Recall there, E2).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `wilmer-rmet-normative-data-set-2022` | main example | Reading the Mind in the Eyes (Baron-Cohen et al., 2001, doi:10.1111/1469-7610.00715), 36 four-option items, 17,680 complete respondents (Kim et al., 2024, doi:10.3758/s13428-023-02323-x). Easy items (p = 0.56–0.86); 2PL slopes 0.21–1.2. Despite four options, 3PL lower asymptotes are near zero (median 0.05; range 0–0.68): easy items say little about the bottom of the curve. BIC prefers the 2PL (5,000-person sample: 205,529 vs. 1PL 206,497, 3PL 205,803, 4PL 205,961). Abilities from all four models correlate 0.97–1.00. | `nominal` (deliberate reuse, E4) |
| `chess_lnirt` | contrast (thread from `rasch` and `likelihood`) | 2PL slopes on the 40 chess problems run from 0.02 (Y15: Elo barely predicts it in `likelihood`, and it fits worst in `rasch`) to 3.8 (Y29, also the steepest Elo slope there); Y15's nearly flat curve crosses every other item's. | `likelihood`, `rasch` (`reuses:`) |

**Decisions (Ben, 09-24):** RMET, not ENEM (C11, A4). The items are photographs of eyes; the lesson describes the task and shows no images (A5).

## Widget / simulation / problem ideas

**Widgets**
- One ICC with sliders for $a$, $b$, $c$, $u$ and the Rasch curve as a ghost (idea 1).
- Weighted sum score: five items with unequal slopes; patterns with the same $\sum a_i x_i$ share an MLE, patterns with the same plain sum don't. Extends `rasch`'s widget (idea 2).
- Identification: the Rasch fit (slopes 1, SD of $\theta$ free) against the common-slope 1PL ($\theta$ SD 1, slope free); identical probabilities (idea 3).

**Predict-then-check:** RMET items have four options. What lower asymptote will the 3PL estimate? Answered by the guessing parameters (median 0.05, not 0.25).

**Simulate:** 3PL data with $c = 0.25$; fit 1PL, 2PL and 3PL; compare recovered parameters and abilities; vary the sample size to see $\hat c$ wobble while the abilities barely move (slide 61).

**Problems**
1. Derivation: show that under the 2PL, $\sum_i a_i x_i$ is sufficient for $\theta$, and that under the 3PL no simple statistic is.
2. Derivation: for the 3PL, at $\theta = b$ the probability is $(1+c)/2$, not 0.5. What does $b$ mean now?
3. Real data with a twist: fit the 2PL and 3PL to the RMET using only respondents in the bottom quarter of sum scores. Do the lower asymptotes change? Why?
4. Judgment: a colleague wants to report the RMET's 3PL guessing parameters as "the rate at which people guess". What would you tell them?
5. Real data: in the chess data, find two items whose 2PL curves cross where most players sit. For which players is each item easier?
6. Challenge (open): the 1PL, 2PL and 3PL abilities correlate above 0.97. When would the choice of model still matter for a decision about a person?

## Go deeper

- **Sufficiency under the 2PL (weighted sum score) and its loss under the 3PL.** Why: `ability-estimation`, `item-estimation`, `information`. Length: half a page.

## Open questions

- **Deep dive #21 and the IMV.** Issue #21 pairs slope variation with whether the 2PL earns its keep out of sample (IMV), but the IMV is taught later, in `fit-prediction`. *Default:* *Across the IRW* here shows slope variation only; `fit-prediction` reports the IMV half and links back.

## Drafting notes (09-24, #39)

What changed from this outline when the page was drafted, with the numbers recomputed:

- **RMET numbers.** Recomputed on a seeded 5,000-respondent sample (all four fits on the same sample): BIC 2PL 204,337, Rasch 205,192, 3PL 204,617, 4PL 204,707 (the 4PL doesn't converge in 500 EM cycles). 2PL slopes 0.19–1.13. **Median 3PL $c$ = 0.01**, not 0.05 (quartiles 0.00 / 0.16, max 0.57; the full 17,680-respondent 3PL, run separately, gives median 0.012). Ability correlations 0.972–0.999. The predict-then-check answer is "mostly near 0".
- **Why $c$ is near 0, shown:** only 84 of 17,680 respondents (0.48%) score at or below chance (9 of 36).
- **Idea 3 split.** "Reading `mirt`, and what fixes the scale" keeps the parameterization and the unit; the 3PL identification point got its own H3, "What the lower asymptote needs", with a widget (closest 2PL to a 3PL, weighted by where respondents sit) and Domingue et al. (2024). Four widgets instead of three.
- **Chess:** 2PL slopes 0.02 (Y15, $b$ = 136.5, meaningless) to 3.79 (Y29). Y15 and Y29 cross at θ = 0.91, with 82% of players below; grouped proportions confirm the flip. Same-sum-score players: Rasch spread 0.00, 2PL up to 0.63. The common-slope 1PL reproduces the Rasch fit (slope 1.22 = Rasch SD of θ).
- **Asymmetric curves:** described in words (no symbol for the exponent, since notation.md has none); links the IRW asymmetric-models vignette.
- **Deep dive #21:** `deepdives/1pl-to-4pl/compute.R`, summary = SD of log(a) per table (unit-free) plus Rasch-vs-2PL BIC. Pilot only (6 of 316 candidates).
