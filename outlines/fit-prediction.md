<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 7–21, the IMV), PS3#3, PS3#4, PS4#2, and the code ps3/fit.R, ps3/different-links.R, ps4/prediction.R, c6/enem_imv.R. -->

# Model fit and out-of-sample prediction (`fit-prediction`)

Module: irt · Prereqs: 1pl-to-4pl · Core · Status: outline

## Core ideas

1. **Item fit statistics, and what "near 1" means.** Outfit and infit are mean squared standardized residuals. Under the model, outfit's SD is about $\sqrt{2/n}$, so with thousands of respondents a value of 1.08 can be "significant" and 0.68 is far out. Read the size of a misfit, not just its z. *(major)* Sources: Wright & Masters (1982), *Rating scale analysis* (MESA Press; book, to verify); Wu & Adams (2013), "Properties of Rasch residual fit statistics", *Journal of Applied Measurement* 14(4) (no DOI; to verify).
2. **Global fit and model comparison.** Likelihood-ratio tests, AIC and BIC answer *whether* one model beats another; they depend on sample size and don't say *how much*. Limited-information fit ($M_2$) exists for the whole model. Sources: Maydeu-Olivares & Joe (2006), doi:10.1007/s11336-005-1295-9; Stone & Zhang (2003), doi:10.1111/j.1745-3984.2003.tb01150.x.
3. **Predict what you didn't fit.** In-sample fit rewards overfitting; hold out responses, fit on the rest, predict the held-out ones (PS4#2). *(major)* Source: Yarkoni & Westfall (2017), doi:10.1177/1745691617693393.
4. **The IMV: how much better, on a portable scale.** Turn each model's predictions into a coin of equivalent uncertainty; the IMV is the expected return on a bet placed with the better model's coin. It doesn't depend on prevalence, so it compares across datasets. It's always a comparison of two models. *(major)* Sources: Domingue, Rahal, Faul, Freese & Kanopka, the IMV (SocArXiv preprint, doi:10.31235/osf.io/gu3ap_v2); Domingue, Kanopka, Kapoor, Pohl, Chalmers, Rahal & Rhemtulla (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2 (§4: the IMV across 89 dichotomous IRW datasets, the source for c6 slide 21); Domingue et al. (2025), *PLOS ONE* 20, doi:10.1371/journal.pone.0316491. (Ben's own work: first person is natural here. "I'm going to tell you about my kool-aid but you don't have to drink it", c6 slide 8.)
5. **Misspecification you can't see.** Generate data with a non-logistic link and fit the logistic model (PS3#4): parameters shift, and in-sample fit statistics may not notice.

Articles checked on Crossref (09-24) except the two marked.

## Picks up

- Infit and outfit, the empirical plot for a misfitting item (from `rasch`; chess item Y15).
- The 2PL and 3PL (from `1pl-to-4pl`).
- The likelihood; comparing models by likelihood (from `likelihood`).
- The logit vs. the probit and the 1.7 constant (from `rasch`; Camilli 1994).

## Promises / leaves open

- Does a guessing parameter help out of sample? → `guessing-priors`; deep dive #22.
- How much do slopes vary across the IRW? → deep dive #21.
- Is a second dimension worth it? → `dimensionality` (IMV for 2D vs. 1D).
- Person fit and aberrant responding → unpaid (candidate for `irtrees`, rapid responding).
- Fit of polytomous models → `polytomous`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_2` | main example | RCT reading outcome, 20 items, 2,174 students (complete), p-values 0.31–0.83. Rasch outfit ranges from 0.68 to 1.08 against a null SD of about 0.03. The three most overfitting items (15, 8, 16) are high-slope items in a 2PL (a = 2.4, 2.1, 1.6; item 15 has the largest slope); 2PL slopes range 0.47–2.4. Out of sample (5-fold over responses), the 2PL beats the Rasch model by IMV 0.013; the 3PL adds 0.0007 over the 2PL. RMSE barely moves (0.454 → 0.451), which is why the IMV is needed. | `invariance-experience` (reuse to settle at the fairness pass) |
| `gilbert_meta_14` | contrast | A larger RCT outcome with waves; first wave only: 65 items, 3,651 students, p-values from 0.01 to 0.91. 2PL slopes run 0.39–6.4, a much wider spread, yet the 2PL's gain is smaller (IMV 0.009); the 3PL adds nothing (0.000). Items that nearly everyone gets right or wrong are easy to predict under any model. This is the "hard comparison" PS4#2c points at: the two tables differ in length, difficulty range and design (waves). | — |

`gilbert_meta_1` is dropped from this lesson (it belongs to `ctt-reliability`).

## Widget / simulation / problem ideas

**Widgets**
- The null distribution of outfit: n and number of items sliders; the SD tracks $\sqrt{2/n}$; place an observed 1.08 on it (idea 1).
- Overfitting: in-sample vs. held-out error as parameters are added (idea 3).
- The IMV coin: two sets of predictions become two coins; show the bet and its expected return (idea 4; c6 slides 8–14).

**Predict-then-check:** in `gilbert_meta_2`, will the items that "misfit" the Rasch model mostly be noisier than expected (outfit above 1) or more predictable (below 1)? Answered by the outfit table: the extreme misfits are below 1, and they are the high-slope items.

**Simulate:** the Wu & Adams study in miniature (PS3#3): Rasch data at several n; the SD of outfit against $\sqrt{2/n}$. Then generate from a probit link and fit the logistic model (PS3#4).

**Problems**
1. Derivation: show that outfit has expectation near 1 under the model, and where $\sqrt{2/n}$ comes from.
2. Simulation (PS3#3): does the SD of outfit depend on the spread of item difficulties (uniform vs. bimodal)? (Posed as open in 252.)
3. Real data with a twist (PS4#2): compare the 1PL and 2PL out of sample in both tables; for which does the 2PL help more, and why is that a hard question?
4. Derivation (PS4#2a): what RMSE would perfect predictions from the true Rasch model give? Simulate it.
5. Judgment: an item has outfit 1.08, z = 2.7, in 2,174 respondents. Would you drop it?
6. Challenge (open, PS3#4): is there anything special about the logistic link? Fit data generated from other CDFs and describe what breaks.

## Go deeper

- **The null distribution of outfit.** Under the model, each $z^2$ has mean 1; the variance of the mean of $n$ such terms gives roughly $\sqrt{2/n}$ (with the caveat that estimated parameters shrink it). Why: `rasch`, `polytomous`, `item-banks-cat`. Length: half a page.
- **The IMV from a likelihood.** How a mean log-likelihood becomes the weight of an equivalent coin. Why: `dimensionality`, `guessing-priors`, deep dives #21–22. Length: half a page.

## Open questions

- `gilbert_meta_2` is also listed for `invariance-experience`. Deliberate thread (fit here, invariance there) or choose another table there?
- Settled (Ben, 09-24): the 89-dataset comparison is Domingue et al. (2024), §4. First person where Ben gives a verdict (voice rule A).
- Wright & Masters (1982) and Wu & Adams (2013) have no DOIs; confirm the full references.
