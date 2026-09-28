<!-- Outlined and drafted 2026-09-25 (#58). Split from fa-confirmatory at a colleague's suggestion, relayed and approved by Ben on #58: "FA 2 seems too long ... split into two pages: CFA, omega, IRT equivalence; and measurement invariance." The multigroup material (ladder, partial invariance, DASS by sex, CES-D, the invariance widget) moved here from fa-confirmatory. Ben: "start with an example where it works". -->

# Measurement invariance: comparing groups with multigroup CFA (`measurement-invariance`)

Module: fa · Prereqs: fa-confirmatory · Core · Status: draft (09-25, #58)

## Core ideas

1. **One model, two groups.** A multigroup CFA fits the factor model in both groups at once; invariance means the responses depend on the factor, not the group (Meredith, 1993, doi:10.1007/BF02294825; Jöreskog, 1971, doi:10.1007/BF02291366). The ladder: configural, metric (equal loadings: compare variances, correlations, regressions), scalar (equal intercepts or thresholds: compare means); strict (equal unique variances) named only. How the groups are put on one scale: group 2's factor variance is freed at metric, its mean at scalar. *(major)* Sources: Vandenberg & Lance (2000), doi:10.1177/109442810031002; Millsap (2011), doi:10.4324/9780203821961; Putnick & Bornstein (2016), doi:10.1016/j.dr.2016.06.004.
2. **What a broken constraint does to a comparison.** An unequal intercept moves the sum-score gap, and under a scalar model it is spread over the factor mean (bias δ/(kλ) with equal loadings); partial invariance frees the item and recovers the comparison from the rest. *(major)* Source: Byrne, Shavelson & Muthén (1989), doi:10.1037/0033-2909.105.3.456.
3. **Testing the steps.** Scaled χ² differences (Satorra & Bentler, 2001, doi:10.1007/BF02296192); ΔCFI of −0.01 (Cheung & Rensvold, 2002, doi:10.1207/s15328007sem0902_5; Chen, 2007, doi:10.1080/10705510701301834; summarised by Putnick & Bornstein, 2016); score tests to find the constraint that strains, and how many flags turn up by chance.
4. **Choosing an estimator for multigroup fits.** The estimator guide from `fa-confirmatory`, group by group: thresholds per group need every category in every group; identification with ordered items (Wu & Estabrook, 2016, doi:10.1007/s11336-016-9506-0); estimators differ in their difference tests (Sass, Schmitt & Marsh, 2014, doi:10.1080/10705511.2014.882658); WLSMV with pairwise deletion and missing data (Chen, Wu, Garnier-Villarreal, Kite & Jia, 2020, doi:10.1080/00273171.2019.1608799).

All references checked on Crossref (09-25); the ΔCFI criterion and its attribution checked against the text of Putnick & Bornstein (2016, PMC5145197).

## Picks up

- The common factor model, loadings, and response formats as a grouping (problem 4) (from `fa-exploratory`).
- CFA in `lavaan`, identification, fit indices, scaled difference tests (from `fa-confirmatory`).
- The estimator guide: ML, MLR, WLSMV, FIML (thread estimator-choice, from `fa-confirmatory`).
- The DASS-21 three-factor model and its keying (from `fa-confirmatory`).

## Promises / leaves open

- Invariance item by item, matching on an observed score; loadings ↔ non-uniform DIF, intercepts ↔ uniform DIF → `dif` (an "if you've done" Recall there, E2).
- The invariance ladder for whole-scale fairness, fitted with an item response model → `fairness` (an "if you've done" Recall there, E2).
- Occasions and treatments in place of groups (longitudinal invariance) → `invariance-experience` (an "if you've done" Recall there, E2).
- Multigroup SEM: comparing structural paths needs metric invariance → `sem` (thread `measurement-invariance`; sem now lists this lesson as a prerequisite).
- Invariance across many groups (alignment, approximate invariance) → unpaid (problem 6, open).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `neurodegenerative_huizinga_2019_dass` | main example: the ladder holds | DASS-21 by `cov_sex` (577 / 669; 2 = women by a count match with the paper's Table 1). MLR: metric Δχ² 13.5 on 18 (p = 0.76), scalar 24.6 on 18 (p = 0.14), robust CFI 0.931–0.932; largest score test item 16's intercept, 6.9 among 39; women +0.09 / +0.16 / +0.18 SD. WLSMV fit indices 0.978–0.987. | `fa-confirmatory` (reuse recorded: the same scale, now by sex) |
| `alexandrowicz_2018_cesd` | failure case | CES-D by `cov_sex` (246 / 262 complete; 2 probably women). Two factors (16 symptom items, 4 positive-affect items). Configural robust CFI 0.902; metric Δχ² 51.3 on 18 (p < .001), ΔCFI −0.029; the crying item's loading strains most (11.7); freed, partial metric 28.1 on 17 (p = 0.04); then its intercept (7.6); partial scalar 25.5 on 17 (p = 0.08). Symptom-factor mean 0.21 SD (full scalar) → 0.18 (partial). Binary WLSMV check: the crying loading again first (33.7). | `dif` (problem 3 there; reuse recorded) |
| (sanity) simulation | sanity | The webR simulation: one shifted intercept, found by the score test, mean recovered by partial invariance. | — |

## Widget / simulation / problem ideas

**Widgets**
- One item that works differently: expected response lines in two groups, sum-score gap (idea 2; moved from `fa-confirmatory`).
- What the scalar constraint does to the factor mean: estimated mean under full and partial scalar invariance, and the power of the scalar-step test against n (idea 2, 3).
- How many flags by chance: the chance that at least one of m score tests falls below α (idea 3).

**Predict-then-check:** the CES-D metric step fails; which item's loading strains most? (crying spells, 11.7).

**Simulate:** two groups, six continuous items, item 6's intercept 0.4 higher in group B; ladder, score tests, partial invariance; group B's mean against the truth.

**Problems**
1. Derivation: the sum-score gap and the scalar model's bias δ/(kλ).
2. Real data with a twist: the CES-D by age (median split).
3. Judgment: Δχ² against ΔCFI at N = 20,000.
4. Design: DASS by education (moved from `fa-confirmatory`).
5. Real data: are lavaan's default ordinal metric and scalar models nested? A nested sequence after Wu & Estabrook (2016).
6. Challenge (open): thirty countries; alignment (Asparouhov & Muthén, 2014, doi:10.1080/10705511.2014.919210).

## Go deeper

- None. The bias formula is problem 1.

## Open questions

- None. The split and the lesson's place (after `fa-confirmatory`, before `fairness` and `dif` in the first course) are Ben's (#58).

## Drafting notes (09-25, #58)

- The CES-D is a worked failure case here, not only a problem as in `fa-confirmatory` (where it was problem 4 to fit one session). Its configural model has two factors (16 symptom items; Radloff's positive-affect items 4, 8, 12, 16, as listed in Alexandrowicz et al., 2018, Table 1) rather than one: one factor fit poorly (robust CFI 0.83).
- The WLSMV check on the DASS reports fit indices only: `lavaan`'s default ordinal metric model fixes the 21 scale factors and 3 factor means that its scalar model frees, so the two are not nested (shown in the code; problem 5 builds a nested sequence).
- The CES-D's top categories are too sparse for thresholds in each group (7 items in group 1 and 5 in group 2 have at most one response at 3), so its ordinal check dichotomizes (any symptom against none) and uses the theta parameterization.
- Verdict (for Ben): when one item breaks scalar invariance, free it and report the comparison both ways rather than drop the item.
