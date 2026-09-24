<!-- Outlined 2026-09-24 from EDUC 252 slides c2 (slides 41–43), PS2#4, PS2#5, ps2/ctt_failures.R and ps2/towards_irt.R. Tidied 09-24 (#62): Ben's answer C5 applied; settled questions folded in; citations verified. -->

# Where CTT breaks: toward item response models (`ctt-limits`)

Module: ctt · Prereqs: ctt-reliability, likelihood · Core · Status: outline

## Core ideas

The simulation is the lesson's argument and stays in the main line (digest C5). References verified 09-24 against Crossref unless noted; table citations from IRW biblio.

1. **Coin flips have no reliability.** *(major)* Respondents flipping fair coins give alpha near zero, whatever the test length. Reliability needs structure shared across items (alpha: Cronbach, 1951, doi:10.1007/BF02310555; KR-20: Kuder & Richardson, 1937, doi:10.1007/BF02288391).
2. **CTT doesn't say how item responses arise.** *(major)* The PS2#4 generator: set a known reliability and the right item p-values, but fill in each respondent's correct answers at random across items. True reliability is what we set, yet KR-20 collapses. $X = T + E$ is silent about items exactly where alpha depends on them (Lord & Novick, 1968, *Statistical Theories of Mental Test Scores*, Addison-Wesley; no DOI, verified via Guttman's 1969 review, doi:10.1017/s0033312300004622). Alpha's bound can be loose (Sijtsma, 2009, doi:10.1007/s11336-008-9101-0).
3. **What was missing: respondents who score higher should be more likely to get each item right.** *(major)* Plot each item's proportion correct against the sum score: rising, S-shaped curves, shifted by difficulty (nonparametric item curves: Ramsay, 1991, doi:10.1007/BF02294494). And the sum score itself depends on which items were taken: the same respondent scores differently on the easy and the hard half.
4. **Logistic regression of an item on the sum score.** Intercepts track difficulty; the slope says how sharply the item separates respondents. One step from an item response model.
5. **Not every item rises.** Unfolding items (attitudes to capital punishment) peak in the middle: respondents with extreme views on either side reject a moderate statement (Andrich, 1988, doi:10.1177/014662168801200105; model in `unfolding`).

## Picks up

- Alpha, KR-20, true and observed scores; one error variance for everyone (from `ctt-reliability`).
- Alpha is a lower bound, and can be a loose one (from `ctt-reliability`, whose Limitations section points here).
- Logistic regression and the likelihood (from `likelihood`).
- Sum scores, item means (from `irw-data`).

## Promises / leaves open

- Item curves against ability, not the sum score → `rasch`.
- Items differ in slope → `1pl-to-4pl`.
- The sum score contains the item (part-whole) → `rasch` (conditioning on the sum score is the sufficiency argument); problem 3 here tries the rest score.
- The sum score depends on which items were taken → `rasch`, `competitions`.
- One error variance for everyone fails → `information`.
- Unfolding response processes → `unfolding` (reuses `andrich_mudfold`, recorded).
- Testlets share a context (local dependence) → `dimensionality`, `explanatory-irt` (Wainer & Kiely, 1987, doi:10.1111/j.1745-3984.1987.tb00274.x).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `4thgrade_math_sirt` | main example | 30 dichotomous items, 664 students (complete), proportions correct 0.20–0.89, in testlets and three domains (arithmetic, measurement, geometry). Item-by-sum-score curves rise, S-shaped, shifted by difficulty. Source: the `sirt` package (Robitzsch, 2022, R package 3.12-66, https://CRAN.R-project.org/package=sirt; GPL-3). | — |
| `andrich_mudfold` | failure case (for the monotone model) | Eight statements about capital punishment (Andrich, 1988), 54 complete respondents. Several items don't rise steadily with the sum score (LIFESACRED: 0.87 at a sum of 3, 0.00 at 5); with 54 respondents the curves are noisy, and the prose says so. | `unfolding` (deliberate thread, agreed by Ben 09-24; recorded under `reuses:`) |

Numbers from the 09-24 outline pass (not recomputed). No other IRW unfolding table shows the single-peaked curve against a sum score (checked 09-24; `eurpar2_mudfold` and `franco_2024_unfolding` went to `unfolding`, #52). Sanity: the simulation is its own known answer.

## Widget / simulation / problem ideas

**Widgets**
- Coin-flip test: items, respondents, and a "shared structure" slider from 0 (coins) up; alpha responds (idea 1).
- The devious generator: set true reliability and p-values; watch true reliability hold while KR-20 falls (idea 2).
- Item vs. sum score: pick an item, see its proportions correct by sum score with a fitted logistic curve (ideas 3, 4).

**Predict-then-check:** for the capital-punishment statements, will the proportion agreeing rise with the sum score for every item? Answered by the mudfold curves.

**Simulate:** the CTT-failures generator from PS2#4 (small: 50 items, 500 respondents, a few replications): scatter true reliability against KR-20.

**Problems**
1. Derivation: show that KR-20 has expectation approximately zero for independent coin flips.
2. Judgment (PS2#4): narrate the logic of the devious generator. Which CTT assumption does it respect, and what does it exploit?
3. Real data with a twist (PS2#5): logistic regressions of an easy and a hard math item on the sum score; compare intercepts with your sense of difficulty. Then use the rest score instead. What changes?
4. Real data: do items in the same testlet correlate more with each other than with items in other testlets?
5. Design: write a statement about a topic you know that should unfold, and one that shouldn't. Why?
6. Challenge (open): the curves in idea 3 use the sum score as the x-axis. What would you need to replace it with a quantity measured without error?

## Go deeper

- None.

## Open questions

- None. Settled: the simulation stays in the main line (C5); `andrich_mudfold` returns in `unfolding` as a recorded reuse.
