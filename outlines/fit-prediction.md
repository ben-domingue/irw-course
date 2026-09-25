<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 7–21, the IMV), PS3#3, PS3#4, PS4#2, and the code ps3/fit.R, ps3/different-links.R, ps4/prediction.R, c6/enem_imv.R. Tidied 09-24 (#62): Ben's answers applied (C16); pick-ups checked against the drafted `likelihood` and `rasch`. -->

# Model fit and out-of-sample prediction (`fit-prediction`)

Module: irt · Prereqs: 1pl-to-4pl · Core · Status: draft

## Core ideas

1. **Item fit statistics, and what "near 1" means.** `rasch` introduced outfit and infit and read them informally. Here: under the model, outfit's SD is about $\sqrt{2/n}$, so with thousands of respondents 1.08 can be "significant" and 0.68 is far out. Read the size of a misfit, not only its z. *(major)* Sources: Wright & Masters (1982), *Rating scale analysis*, MESA Press (book, no DOI); Wu & Adams (2013), *Journal of Applied Measurement* 14(4), 339–355 (no DOI; PubMed 24064576).
2. **Global fit and model comparison.** Likelihood-ratio tests, AIC and BIC say *whether* one model beats another; they depend on sample size and don't say *how much*. Limited-information fit ($M_2$) for the whole model. Sources: Maydeu-Olivares & Joe (2006), doi:10.1007/s11336-005-1295-9; Stone & Zhang (2003), doi:10.1111/j.1745-3984.2003.tb01150.x.
3. **Predict what you didn't fit.** In-sample fit rewards overfitting; hold out responses, fit on the rest, predict the held-out ones (PS4#2). *(major)* Source: Yarkoni & Westfall (2017), doi:10.1177/1745691617693393.
4. **The IMV: how much better, on a portable scale.** Turn each model's predictions into a coin of equivalent uncertainty; the IMV is the expected return on a bet placed with the better model's coin. It doesn't depend on prevalence, so it compares across datasets, and it always compares two models. *(major)* Sources: Domingue, Rahal, Faul, Freese, Kanopka, Rigos & Stenhaug (2025), *PLOS ONE* 20(3), e0316491, doi:10.1371/journal.pone.0316491 (the IMV; published version of the SocArXiv preprint doi:10.31235/osf.io/gu3ap_v2); Domingue, Kanopka, Kapoor, Pohl, Chalmers, Rahal & Rhemtulla (2024), *Psychometrika* 89(3), 1034–1054, doi:10.1007/s11336-024-09977-2 (§4: the IMV across 89 dichotomous IRW datasets, the source for c6 slide 21).
5. **Misspecification you can't see.** Generate data with a non-logistic link and fit the logistic model (PS3#4): parameters shift, and in-sample fit statistics may not notice. Sources: Camilli (1994), doi:10.3102/10769986019003293 (logit vs. normal ogive); Bazán, Branco & Bolfarine (2006), doi:10.1214/06-BA128 (a skewed link).

DOIs Crossref-checked 09-24.

**First person (C16):** the IMV is Ben's work. First person where he gives a verdict (voice rule A), e.g. on reading a small outfit misfit in a large sample, or on when a 0.01 IMV is worth a model's extra parameters; the method itself is described in the third person, with its citations.

## Picks up

- Infit and outfit; most of the worst-fitting chess items overfit, Y15 underfits (outfit above 2); the empirical plot; "the formal version of this check is in *Model fit*" (from `rasch`).
- The 2PL and 3PL; BIC's verdict on the RMET (from `1pl-to-4pl`).
- Slope variation across the IRW, *Across the IRW* in `1pl-to-4pl` (thread from `1pl-to-4pl`, deep dive #21): this lesson adds the IMV half.
- The likelihood; comparing models by `logLik()` (from `likelihood`, problem 3).
- The logit vs. the normal CDF, and $D \approx 1.7$ (from `rasch`, the ICC widget's challenge).

## Promises / leaves open

- Does a guessing parameter help out of sample? → `guessing-priors` (deep dive #22, home there).
- Is a second dimension worth it? → `dimensionality` (IMV for 2D vs. 1D).
- Fit of polytomous models → `polytomous`.
- The IMV and out-of-sample comparison, reused → `cdm`, `ai-psychometrics`, `response-time`, `trials` (not descendants; each restates it briefly, E2).
- The null distribution of outfit, for screening bank items → `item-banks-cat` (a pointer there; not a descendant, E2).
- Person fit and aberrant responding → unpaid (candidate for `irtrees`, rapid responding).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_2` | main example | RCT reading outcome, 20 items, 2,174 students (complete), p-values 0.31–0.83. Rasch outfit ranges from 0.68 to 1.08 against a null SD of about 0.03. The three most overfitting items (15, 8, 16) are high-slope items in a 2PL (a = 2.4, 2.1, 1.6; item 15 has the largest slope); 2PL slopes range 0.47–2.4. Out of sample (5-fold over responses), the 2PL beats the Rasch model by IMV 0.013; the 3PL adds 0.0007 over the 2PL. RMSE barely moves (0.454 → 0.451), which is why the IMV is needed. | — |
| `gilbert_meta_14` | contrast | A larger RCT outcome with waves; first wave only: 65 items, 3,651 students, p-values 0.01–0.91. 2PL slopes run 0.39–6.4, a much wider spread, yet the 2PL's gain is smaller (IMV 0.009); the 3PL adds nothing (0.000). Items nearly everyone gets right or wrong are easy to predict under any model. This is the "hard comparison" PS4#2c points at: the tables differ in length, difficulty range and design (waves). | — |

`gilbert_meta_1` belongs to `ctt-reliability`. `gilbert_meta_2` is no longer listed for `invariance-experience` (it uses `gilbert_meta_20` and `_37`), so there is no reuse to record.

## Widget / simulation / problem ideas

**Widgets**
- The null distribution of outfit: n and number-of-items sliders; the SD tracks $\sqrt{2/n}$; place an observed 1.08 on it (idea 1).
- Overfitting: in-sample vs. held-out error as parameters are added (idea 3).
- The IMV coin: two sets of predictions become two coins; the bet and its expected return (idea 4; c6 slides 8–14).

**Predict-then-check:** `gilbert_meta_14`'s 2PL slopes spread far wider (0.39–6.4) than `gilbert_meta_2`'s (0.47–2.4). Will the 2PL's out-of-sample gain over the Rasch model be larger or smaller there? Answered by the IMVs: smaller (0.009 vs. 0.013), because near-certain items are easy to predict under any model. (`rasch` already asked the overfit-or-underfit question on chess, so it isn't repeated; `gilbert_meta_2`'s outfit table confirms it in passing.)

**Simulate:** Wu & Adams in miniature (PS3#3): Rasch data at several n; the SD of outfit against $\sqrt{2/n}$. Then data from a probit link, fitted with the logistic model (PS3#4).

**Problems**
1. Derivation: show that outfit has expectation near 1 under the model, and where $\sqrt{2/n}$ comes from.
2. Simulation (PS3#3): does the SD of outfit depend on the spread of item difficulties (uniform vs. bimodal)? (Open in 252.)
3. Real data with a twist (PS4#2): compare the 1PL and 2PL out of sample in both tables; for which does the 2PL help more, and why is that a hard question?
4. Derivation (PS4#2a): what RMSE would perfect predictions from the true Rasch model give? Simulate it.
5. Judgment: an item has outfit 1.08, z = 2.7, in 2,174 respondents. Would you drop it?
6. Challenge (open, PS3#4): is there anything special about the logistic link? Fit data generated from other CDFs and describe what breaks.

## Go deeper

- **The null distribution of outfit.** Each $z^2$ has mean 1; the variance of a mean of $n$ such terms gives roughly $\sqrt{2/n}$ (estimated parameters shrink it). Why: `polytomous`, `item-banks-cat`. Length: half a page.
- **The IMV from a likelihood.** How a mean log likelihood becomes the weight of an equivalent coin. Why: `dimensionality`, `guessing-priors`, deep dives #21–22. Length: half a page.

## Open questions

- None.

## Drafted (2026-09-24, #41): what changed

- **Everything recomputed** (IRW v59 pins; `mirt` 1.46.1). `gilbert_meta_2`: outfit 0.68–1.08 (EAP abilities), null SDs 0.019–0.057; 5-fold IMVs 0.125 (Rasch over item proportions), 0.012 (2PL over Rasch), 0.0001 (3PL over 2PL; 0.0035 in-sample); RMSE 0.454 → 0.451. `gilbert_meta_14` (baseline wave, 65 items, 3,651 students): slopes 0.39–6.43, IMV 0.0088; 0.0015 on the 21 items under 10% correct, 0.0154 on the rest (this breakdown is new and carries the predict-then-check's "why"). The 3PL isn't fitted to `gilbert_meta_14` (minutes of fitting for a result the lesson doesn't use).
- **New finding, added to idea 1:** `mirt`'s `itemfit()` uses EAP abilities by default, and with 20 items EAP pulls outfit to about 0.90 when the Rasch model is true (0.97–0.99 with ML abilities). *Simulate* shows it; *With real data* reports both (`gilbert_meta_2` median 0.92 vs 1.00). The Go deeper derives the exact null variance, Var(z²) = 1/(pq) − 4, which shows √(2/n) is a rough rule whose accuracy depends on item location (PS3#3's open question, now problem 2).
- **Idea 2:** Andersen's LR test is computed in base R from conditional ML (459 on 19 df); it points at the same high-slope items.
- **Widgets:** four, not three. The fourth (idea 5) fits the closest 2PL to a non-logistic curve (reusing `closest2pl` from `1pl-to-4pl.js`).
- **First-person verdicts:** reading size and z together (idea 1); the 2PL for `gilbert_meta_2`, on a 0.01 IMV being worth a parameter per item and 0.0001 not.
- **Deep dive #21, IMV half:** `deepdives/fit-prediction/compute.R` written; pilot run (5 of 316 tables) committed. The full run is Ben's.
- **Citation corrected:** Bazán, **Bolfarine & Branco** (2006) (Crossref order); the PLOS ONE paper has eight authors (adds Tripathi).
