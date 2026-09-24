<!-- Outlined backwards from lessons/rasch.qmd (draft), 2026-09-24. -->

# The Rasch model (`rasch`)

Module: irt · Prereqs: ctt-limits · Core · Status: outline (page is a draft)

## Core ideas

1. **The Rasch model is logistic regression with nothing observed on the right.** Write $\Pr(x_{ij}=1)$ in terms of $\theta_j - b_i$; read an ICC. *(major)*
2. **The scale has no origin.** Only $\theta - b$ matters, so software fixes a constraint; results can differ by a shift. *(major)*
3. **People and items share one scale.** The Wright map shows whether a test is targeted at the people who took it.
4. **The model's assumptions.** Unidimensionality and local independence; brainstorm how each fails.
5. **The sum score is sufficient for $\theta$.** Patterns with the same sum score get the same estimate; the 2PL breaks this. *(major)*
6. **Specific objectivity.** Non-crossing ICCs make item comparisons independent of the people; it is a demand on the data, not a gift. *(major)*

A short note closes Core ideas: estimation is hard because nothing is known; `mirt` does it for now.

## Picks up

- Logistic regression and the likelihood (from `likelihood`).
- Sum scores treat items as interchangeable; the sum score vs. item relationship is not linear (from `ctt-limits`).
- Long IRW format, reshaping to wide, dropping empty respondents (from `irw-data`).
- Probit regression, for the optional $D \approx 1.7$ aside (from outside the course; not taught earlier).

## Promises / leaves open

- The slope slider previews the 2PL; equal slopes is testable → `1pl-to-4pl`.
- Specific objectivity fails when ICCs cross → `1pl-to-4pl` (crossing ICCs in chess), `parameter-invariance`.
- Sum score sufficiency holds only under Rasch → `1pl-to-4pl` (2PL weights items), `ability-estimation`.
- Precision depends on where you are on the scale (Wright map) → `information`.
- The scale has no origin; compare across studies with care → `equating`.
- Unidimensionality → `dimensionality`, `fa-confirmatory`.
- Local independence (passages, repeated trials) → `dimensionality`, `explanatory-irt`.
- How abilities and item parameters are estimated (EM, then abilities given items) → `ability-estimation`, `item-estimation`.
- Formal fit checks, and outfit's sampling distribution → `fit-prediction`.
- Is a wide spread of difficulty typical? (diffsim vignette baseline) → `rasch` itself, TODO in the page (#3).
- Are equal slopes plausible in typical data? → deep dive #21 (slopes across the IRW).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `chess_lnirt` | main example | Wide difficulty spread (Y31 about −5, Y30 about +3.5); well targeted; most misfit is *overfit* (items sharper than a common slope), with Y15 the noisy exception (outfit > 2). | `irw-data`, `likelihood`, `ctt-limits`: reuse to resolve in #12. Keep here if `1pl-to-4pl` returns to it as a thread (crossing ICCs). |
| `wirs` | contrast | Six survey items; empirical proportions jump around the model curve; abilities bunch in a narrow range. | — |

## Widget / simulation / problem ideas

**Widgets**
- ICC: sliders for $b$ and slope, normal-CDF overlay (ideas 1, previews 2PL).
- Shift everything: add $C$ to all $\theta$ and $b$, probabilities don't move (idea 2).
- Wright map: mean ability, mean difficulty, difficulty spread (idea 3). Carries the optional Core-ideas predict ("average person 1.5 logits above the average item: what proportion right?").
- Sufficiency: pick a pattern of 5 items, see estimates for every pattern with that sum score; toggle Rasch/2PL (idea 5).
- Do the curves cross? Two items, B's slope adjustable (idea 6).

**Predict-then-check:** among the worst-fitting chess items, do you expect overfit or underfit? Answered by the infit/outfit table.

**Simulate:** Rasch data with `np` people and `ni` items; fit with `mirt`; plot estimated vs. true difficulties; vary `np` (50, 2000) and `ni`. Note that `mirt`'s `d` is an easiness.

**Problems**
1. Derivation: the logit identity; log-odds = $\theta - b$; what one unit of $\theta$ does to the odds.
2. Derivation / judgment: additive vs. multiplicative indeterminacy; what the Rasch model does pin down.
3. Real data with a twist: plot proportions correct against raw `d`; explain the sign from the `mirt` docs.
4. Design: Wright map for chess; who gets least information; propose two items to add.
5. Judgment: empirical fit plots in chess vs. wirs vs. simulated Rasch data; what good fit looks like.
6. Challenge: two chess players with the same sum score, different patterns; compare `fscores` under Rasch and 2PL.

## Go deeper

- **The sum score is sufficient (agreed target, not yet in the page).** Factorize the likelihood so it depends on $\theta$ only through $r$; conditioning on $r$ removes $\theta$, which gives conditional ML and makes specific objectivity a theorem. Converse (Andersen): sufficiency implies Rasch. Why: `1pl-to-4pl`, `ability-estimation`, `item-estimation`, `parameter-invariance`. Length: about a page.

## Open questions

- None new. Ben's verdict on equal slopes is pending in the page (#3, tracked in #62); the baseline for "wide spread" is Claude's to add.
