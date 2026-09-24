<!-- Outlined 2026-09-24 from EDUC 252 slides c2 (slides 41–43), PS2#4, PS2#5, ps2/ctt_failures.R and ps2/towards_irt.R. -->

# Where CTT breaks: toward item response models (`ctt-limits`)

Module: ctt · Prereqs: ctt-reliability, likelihood · Core · Status: outline

## Core ideas

1. **Coin flips have no reliability.** People flipping fair coins give alpha near zero, whatever the test length. Reliability needs structure shared across items. *(major)*
2. **CTT doesn't say how item responses arise.** Generate data with a known reliability and the right item p-values, but fill in each person's correct answers at random across items: true reliability is what we set, yet KR-20 collapses. The model is silent exactly where alpha depends on it. *(major)*
3. **What was missing: people who score higher should be more likely to get each item right.** Plot the proportion correct on each item against the sum score: rising, S-shaped curves, shifted by difficulty. *(major)*
4. **Logistic regression of an item on the sum score.** Intercepts track difficulty; the slope says how sharply the item separates people. One step from an item response model.
5. **Not every item rises.** Unfolding items (attitudes to capital punishment) peak in the middle: extreme views on either side reject a moderate statement.

## Picks up

- Alpha, KR-20, true and observed scores (from `ctt-reliability`).
- Logistic regression and the likelihood (from `likelihood`).
- Sum scores, item means (from `irw-data`).
- Alpha is a lower bound but can be loose (thread from `ctt-reliability`).

## Promises / leaves open

- Item curves against ability, not sum score → `rasch`.
- Items differ in slope → `1pl-to-4pl`.
- The sum score contains the item (part-whole) → `rasch` (conditioning on the rest score is a sufficiency argument), unpaid otherwise.
- One error variance for everyone fails → `information`.
- Unfolding response processes → `unfolding-nominal`.
- Testlets share a context (local dependence) → `dimensionality`, `explanatory-irt`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `4thgrade_math_sirt` | main example | 30 dichotomous items, 664 students (complete), proportions correct 0.20–0.89, in testlets and three domains (arithmetic, measurement, geometry). Item-by-sum-score curves rise, S-shaped, shifted by difficulty. | — |
| `andrich_mudfold` | failure case (for the monotone model) | Eight statements about capital punishment, 54 complete respondents. Several items don't rise steadily with the sum score (LIFESACRED: 0.87 at a sum of 3, 0.00 at 5); with 54 people the curves are noisy, so the prose should say so. | `unfolding-nominal` (deliberate thread?) |

`chess_lnirt` moves out of this lesson (#12), replaced by `4thgrade_math_sirt`.

## Widget / simulation / problem ideas

**Widgets**
- Coin-flip test: items, people, and a "shared structure" slider from 0 (coins) up; alpha responds (idea 1).
- The devious generator: set true reliability and p-values; watch the true reliability hold while KR-20 falls (idea 2).
- Item vs. sum score: pick an item, see its proportions correct by sum score with a fitted logistic curve (ideas 3, 4).

**Predict-then-check:** for the capital-punishment statements, will the proportion agreeing rise with the sum score for every item? Answered by the mudfold curves.

**Simulate:** the CTT-failures generator from PS2#4 (small: 50 items, 500 people, a few replications): scatter true reliability against KR-20.

**Problems**
1. Derivation: show that KR-20 has expectation zero (approximately) for independent coin flips.
2. Judgment (PS2#4): narrate the logic of the devious generator. Which CTT assumption does it respect, and what does it exploit?
3. Real data with a twist (PS2#5): logistic regressions of an easy and a hard math item on the sum score; compare intercepts with your sense of difficulty. Then use the rest score instead of the sum score. What changes?
4. Real data: in the math data, do items in the same testlet correlate more with each other than with items in other testlets?
5. Design: write a statement about a topic you know that should unfold, and one that shouldn't. Why?
6. Challenge (open): the curves in idea 3 use the sum score as the x-axis. What would you need to replace it with a quantity measured without error?

## Go deeper

- None.

## Open questions

- The page stays mostly simulation (the "guided tour" of PS2#4). Fine as is, or split the devious generator into a Go deeper?
- Thread: `andrich_mudfold` could return in `unfolding-nominal`, which is optional. Keep it in both?
