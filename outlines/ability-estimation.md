<!-- Outlined 2026-09-24 from EDUC 252 slides c4 (slides 44–48) and c5 (slides 64–66), PS3#2, PS4#1, PS5#2, ps3/1_abilities.R and ps5/eap_versus_mle.R. Tidied 09-24 (#62): Ben's answers applied (C12); pick-ups checked against the drafted `likelihood` and `rasch`. -->

# Estimating abilities: MLE and EAP (`ability-estimation`)

Module: irt · Prereqs: information · Core · Status: outline

## Core ideas

1. **With item parameters known, ability is a one-parameter likelihood problem.** Likelihood surfaces for each response pattern; the MLE solves the score equation $\sum_i a_i(x_i - p_i) = 0$ by Newton–Raphson (for the Rasch model, expected score = observed score). Its SE is $1/\sqrt{I(\hat\theta)}$, from `information`. *(major)* Sources: Lord (1980), doi:10.4324/9780203056615; Baker & Kim (2004), *Item response theory: Parameter estimation techniques* (2nd ed.), doi:10.1201/9781482276725.
2. **No MLE for perfect patterns.** All-correct and all-wrong patterns have likelihoods that never peak, so the MLE is $\pm\infty$: the item-response version of separation, which `likelihood` flagged and handed here. How common it is depends on the test. *(major)* Sources: Albert & Anderson (1984), doi:10.1093/biomet/71.1.1 (via `likelihood`); Warm (1989), doi:10.1007/bf02294627.
3. **EAP: bring in a prior.** The posterior mean over a prior for $\theta$, computed on a grid of nodes. It always exists, shrinks toward the mean, and trades a little bias for lower mean squared error (PS5#2). This is where the course takes up the Bayesian reading `likelihood` set aside. *(major)* Source: Bock & Mislevy (1982), doi:10.1177/014662168200600405.
4. **Other estimators.** WLE (finite for perfect patterns, less biased than the MLE), MAP, and, in one paragraph, plausible values for group-level inference (NAEP, PISA). Sources: Warm (1989); Mislevy (1991), doi:10.1007/bf02294457.
5. **Sufficiency, revisited.** Under the Rasch model every estimator is a function of the sum score; under the 2PL, respondents with the same sum score get different estimates (the weighted sum from `1pl-to-4pl`). Thread from `rasch`. Source: Andersen (1977), doi:10.1007/bf02293746.

DOIs Crossref-checked 09-24.

**Verdict (voice rule A):** which estimate to report for an individual (EAP, with its shrinkage stated) and which not to average for group comparisons.

## Picks up

- The score equation and curvature; no MLE under separation, with "a respondent who answers every item correctly" named there (from `likelihood`, its Go deeper).
- The Bayesian reading of the likelihood: "we return to priors in *Estimating abilities*" (from `likelihood`).
- The Rasch model; the sum score is sufficient, and the sufficiency widget's MLE table with its $\pm\infty$ rows (from `rasch`).
- "Estimate item parameters first, then abilities treating them as known" (from `rasch`, its note on estimation).
- Information and the CSEM; $SE = 1/\sqrt{I}$ (from `information`).
- The 2PL: sum-score sufficiency fails; the weighted sum score (from `1pl-to-4pl`).

## Promises / leaves open

- Where the item parameters come from; EAP's grid of nodes and posterior weights become the E step → `item-estimation`.
- Choosing an estimator for reporting; shrinkage and group comparisons; plausible values in full → `score-meaning` (not a descendant, E10; an "if you've done it" Recall there).
- EAP in adaptive testing → `item-banks-cat`.
- Priors on item parameters → `guessing-priors`.
- Out-of-sample prediction with MLE vs. EAP (PS5#2b): a problem here only; `fit-prediction` compares models, not estimators.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `c19prc_uk_mcbride_2021_wordsum` | main example | The GSS Wordsum vocabulary test (10 items), 2,058 UK adults. 95 score 0 and 156 score 10, so 251 respondents (12%) have no finite MLE. The difficulties fall in two clusters (−2.5 to −1.1 and 0.9 to 1.6) with a gap in the middle, which Cor, Haertel, Krosnick & Malhotra (2012) also point out. MLE, EAP and WLE agree in the middle (a score of 5: −0.57, −0.47, −0.60) and diverge at the ends (a score of 9: 2.55, 2.07, 2.26). EAPs are shrunk: SD 1.7 against a model SD of 1.9. Under a 2PL, the 282 respondents with a score of 5 get 39 different EAPs, from −1.1 to 0.0. | — |

Wordsum sources: Thorndike (1942), doi:10.1037/h0060053; Cor et al. (2012), doi:10.1016/j.ssresearch.2012.05.007. Table citation from IRW biblio.

**Decision (C12):** plausible values get one paragraph here; the full treatment is in `score-meaning`.

## Widget / simulation / problem ideas

**Widgets**
- Likelihood surfaces: three Rasch items; toggle each response; the surface, its peak, and the perfect patterns that never peak (ideas 1, 2).
- Prior × likelihood = posterior on a grid: prior SD slider; MLE, MAP and EAP marked (idea 3).
- Shrinkage: EAP against MLE by sum score, prior SD slider (ideas 3, 4).

**Predict-then-check:** what share of Wordsum respondents have no maximum likelihood estimate? Answered by the score distribution (12%).

**Simulate (PS3#2, PS5#2):** Rasch data with known items; abilities by hand-written MLE (`optim`) and by EAP; bias, variance and RMSE against the truth; vary the number of items.

**Problems**
1. Derivation (PS4#1): the likelihood of the pattern 1-1-0 for items with $b = -1, 0, 1.5$; at what $\theta$ does 1-1-0 become more likely than 1-0-0?
2. Derivation: show that the Rasch MLE solves $\sum_i p_i(\theta) = r$, so it depends only on the sum score $r$.
3. Real data with a twist: Wordsum EAPs with a normal prior of SD 1 vs. the estimated SD. Which respondents move most?
4. Judgment: a school reports EAPs for individual students and compares classroom averages. What goes wrong, and what would you report instead?
5. Simulation (PS5#2): does EAP reduce mean squared error? Is it biased? Where?
6. Challenge (open): 12% of Wordsum respondents sit at the floor or ceiling. What should a survey analyst do with them, and does the answer depend on the question?

## Go deeper

- **No MLE for perfect patterns.** The likelihood of an all-correct pattern increases in $\theta$ for every item, so it has no maximum; the WLE's correction term keeps it finite. Why: `item-banks-cat`, `score-meaning`, `item-estimation` (JML drops these respondents). Length: half a page.

## Open questions

- None.
