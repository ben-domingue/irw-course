<!-- Outlined 2026-09-24 from EDUC 252 slides c1 (slides 42–47), PS1#1, #2, #5 and the c1/ps1 code. Aligned 09-24 (#62) with the finished lesson, lessons/likelihood.qmd: where they differ, the lesson wins. -->

# The likelihood and logistic regression (`likelihood`)

Module: foundations · Prereqs: irw-data · Preliminary · Status: done (lessons/likelihood.qmd)

## Core ideas

As taught in the lesson. References are the lesson's (Crossref-verified DOIs in its *Going further*).

1. **The likelihood.** *(major)* Data held fixed, parameters varied: for coin flips, $L(p \mid y) = p^k(1-p)^{n-k}$ (Fisher, 1922, doi:10.1098/rsta.1922.0009). Not a distribution for $p$; a frequentist reading (used here) and a Bayesian one (priors deferred to `ability-estimation`).
2. **Work on the log scale.** Products of small numbers underflow; the log is monotone, so the maximizer is unchanged.
3. **The likelihood surface and its curvature.** *(major)* More flips, sharper peak; curvature is precision (standard error ∝ 1/√curvature). The lesson uses coin flips; the normal mean is problem 2.
4. **Logistic regression by likelihood.** *(major)* $\ell = \sum y \log p + (1-y)\log(1-p)$, coefficients written $\beta_0, \beta_1$; the derivatives $\sum (y-p)x$ and $\sum (y-p)$ are zero at the maximum, so fitted probabilities add up to the observed successes.
5. **Maximizing in practice.** `optim()` on our own function and `glm()` land on the same answer.
6. **Item responses as a logistic regression.** Chess problems on Elo: one pooled slope, then item intercepts (van der Maas & Wagenmakers, 2005, doi:10.2307/30039042). The slope rises (non-collapsibility, not confounding; Gail, Wieand & Piantadosi, 1984, doi:10.1093/biomet/71.3.431; Mood, 2010, doi:10.1093/esr/jcp006). Verdict: never pool item responses into one logistic regression without item intercepts. Replace Elo with an unknown ability per player and you have the Rasch model.

## Picks up

- Long format: one row per response is what `glm` wants (from `irw-data`; a Recall callout in the lesson).
- Logistic regression itself: assumed from a prior course (the 252 class uses a video); restated briefly.

## Promises / leaves open

Each is a forward link or statement in the lesson unless marked.

- Priors and the Bayesian reading → `ability-estimation` (EAP), `guessing-priors` (not linked in the lesson).
- Curvature ↔ standard error; Fisher information → `information`, `ability-estimation` (SE of θ).
- No MLE under separation; the all-correct respondent → `ability-estimation` (the Go deeper's last paragraph).
- Maximizing numerically (`optim`, Newton steps) → `item-estimation`.
- Comparing models by likelihood → `fit-prediction` (For instructors; problem 3 compares log likelihoods).
- Replace the observed covariate with an unknown ability → `rasch` (logistic regression with nothing observed on the right); Y15 fits worst there.
- Items differ in how strongly Elo predicts success → `1pl-to-4pl` (slopes).
- The Rasch likelihood as a logistic regression with person and item effects (problem 6, `glmer`) → `explanatory-irt`.
- Logistic regression of an item on the sum score → `ctt-limits` (not named in the lesson; `ctt-limits` restates what it needs).
- Logistic regression and the likelihood for paired comparisons → `competitions` (not named in the lesson).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `chess_lnirt` | main example | 40 problems, 256 players, 10,240 responses; Elo standardized. Pooled slope 0.50 (SE 0.021), 0.83 with item intercepts. Per-item slopes run from essentially zero to about 2: Y31 is flat because 98% solve it; Y15 is flat though about as hard as Y29 (8% and 7% solve them), and Y29 is steep. | `rasch`, `1pl-to-4pl` (deliberate, recorded: Elo → θ; Y15 again) |

Citation: van der Maas & Wagenmakers (2005), from IRW biblio.

## Widget / simulation / problem ideas

**Widgets** (as built)
- The likelihood for a coin: flips and heads sliders, toggle to the log likelihood (ideas 1, 2).
- More data, sharper peak: log likelihoods at three sample sizes, peaks aligned (idea 3).
- Fit a logistic regression by hand: intercept and slope sliders on 60 simulated points, with the log likelihood and both derivatives shown (idea 4).

Three quick checks, in ideas 1, 3 and 4.

**Predict-then-check:** when each problem gets its own intercept, does the Elo slope (0.50 pooled) get smaller, stay the same or get larger? It rises to 0.83.

**Simulate:** simulated logistic data; the log likelihood over the slope; `optim()` vs. `glm()`; SE of the slope about 0.43, 0.10 and 0.03 at $n$ = 50, 500 and 5,000.

**Problems** (as in the lesson)
1. The derivative (PS1#5), and its shape for true slopes 0.5 and 2.
2. A normal likelihood at $n$ = 10, 100, 1,000; curvature vs. the SE of a mean (PS1#1).
3. Chess, your way (PS1#2): no item terms, item intercepts, item slopes; compare log likelihoods.
4. Two readings: a frequentist and a Bayesian on "a 95% chance the slope is between 0.46 and 0.54".
5. No maximum: six observations with no MLE; the item-response analogue.
6. Challenge: `glmer` with item intercepts and a player random effect; compare with Elo. What have you fit?

## Go deeper

- **The score equation and the standard error** (in the lesson). The logistic MLE solves $\sum (y-p)x = 0$; the SE is $1/\sqrt{\sum p(1-p)x^2}$; no maximum under separation (Albert & Anderson, 1984, doi:10.1093/biomet/71.1.1). Picked up by `information`, `ability-estimation`, `rasch`, `item-estimation`.

## Open questions

- None. C3 (non-collapsibility in lesson three) is settled: kept, with the sentence saying it isn't confounding, as the lesson has it.
