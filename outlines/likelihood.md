<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 42–47), PS1#1, #2, #5 and the c1/ps1 code. -->

# The likelihood and logistic regression (`likelihood`)

Module: foundations · Prereqs: irw-data · Core · Status: outline

## Core ideas

1. **The likelihood.** Data held fixed, parameters varied: $L(\theta \mid y) = \prod P(y_i \mid \theta)$. A frequentist reading and a Bayesian one. *(major)*
2. **Work on the log scale.** Products of small numbers underflow; the log is monotone, so the maximizer is unchanged.
3. **The likelihood surface.** For a normal mean: its shape, and how it sharpens as $n$ grows. Curvature is precision. *(major)*
4. **Logistic regression by likelihood.** $\ell = \sum y \log p + (1-y)\log(1-p)$; its derivative $\sum (y - p)x$; the maximum is where that is zero. *(major)*
5. **Maximizing in practice.** `optim` and `glm` land on the same answer.
6. **Item responses as logistic regression.** Chess problems on Elo: one slope pooled over items, then item intercepts. The next step (replace the observed Elo with an unknown ability) is the Rasch model.

## Picks up

- Long format: one row per response is what `glm` wants (from `irw-data`).
- Logistic regression itself: assumed from a prior course (the 252 class uses a video); restate briefly.

## Promises / leaves open

- Curvature ↔ standard error → `information` (Fisher information), `ability-estimation` (SE of θ).
- The score equation $\sum (y-p)x = 0$ → `ability-estimation` (Newton–Raphson for θ), `rasch` (the sum score is sufficient).
- Replace the observed covariate with an unknown ability → `rasch` (logistic regression with nothing observed on the right).
- Items differ in how strongly Elo predicts success → `1pl-to-4pl` (slopes), `rasch` (Y15 misfit).
- No MLE when every response is correct (separation) → `ability-estimation` (perfect patterns).
- Priors → `ability-estimation` (EAP), `guessing-priors`.
- Comparing models by likelihood → `fit-prediction`.
- Logit vs. probit → `rasch` (D ≈ 1.7, Camilli 1994).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `chess_lnirt` | main example | Elo predicts success: pooled slope 0.50 per unit of Elo, 0.83 once items get their own intercepts. Per-item slopes run from 0.03 (Y15, Y31) to 2.0 (Y29). | `rasch` (deliberate thread: Elo → θ; Y15 again) |

One table: the lesson is about the likelihood, and the data are there to show logistic regression on responses.

## Widget / simulation / problem ideas

**Widgets**
- Coin flips: fixed data, drag $p$, watch $L$ and $\log L$; add flips and watch the peak sharpen (ideas 1–3).
- Normal-mean surface with an $n$ slider (idea 3).
- Logistic-regression surface over $(b_0, b_1)$: click a point to see its fitted curve against the data (idea 4).
- The derivative $\sum (y-p)x$ plotted against $b$; move the true $b$ (PS1#5) (idea 4).

**Predict-then-check:** when items get their own intercepts, does the Elo slope go up, down or stay the same? Answered by the two fits (it rises, 0.50 to 0.83). Leaving out item differences flattens a logistic slope even though Elo is unrelated to which item was asked.

**Simulate:** simulate logistic data; plot the log likelihood over $b_1$; compare `optim` with `glm`; vary $n$.

**Problems**
1. Derivation (PS1#5): derive the log likelihood and its derivative $\sum (y-p)x$.
2. Derivation and simulation (PS1#1): the normal-mean surface as $n$ varies; connect its curvature to the standard error.
3. Real data with a twist (PS1#2): chess on Elo; how should you account for responses coming from different items?
4. Judgment: read the same surface as a frequentist and as a Bayesian.
5. Design: construct a small dataset for which the MLE doesn't exist, and explain why.
6. Challenge: fit chess with item intercepts and a person random effect (`glmer`) in place of Elo. Compare the estimated person effects with Elo. What have you fit?

## Go deeper

- **The score equation and its curvature.** The logistic MLE solves $\sum (y-p)x = 0$, and its standard error is $1/\sqrt{\sum p(1-p)x^2}$. Why: `information`, `ability-estimation`, `rasch` (sufficiency), `item-estimation`. Length: half a page.

## Open questions

- The predict-then-check turns on non-collapsibility of the logistic model (the slope rises without confounding). Too subtle for lesson three, or a good early surprise?
