<!-- Outlined backwards from lessons/ctt-reliability.qmd (draft), 2026-09-24. -->

# Classical test theory and reliability (`ctt-reliability`)

Module: ctt · Prereqs: constructs, irw-data · Core · Status: outline (page is a draft)

## Core ideas

1. **True scores and error.** $X = T + E$; the variance splits; reliability is $\sigma^2_T/\sigma^2_X$, which can't be computed directly. *(major)*
2. **Parallel forms.** Their correlation equals reliability; the standard error of measurement is what reliability means for one person. *(major)*
3. **Alpha from one administration.** Items as little parallel tests; KR-20 for 0/1 items; alpha equals reliability only under (essential) tau-equivalence and is otherwise a lower bound. *(major)*
4. **Split halves and Spearman–Brown.** Lengthening and shortening; alpha is the average adjusted split half.
5. **Item analysis and reading your items.** Item means and item-rest correlations; reverse keying can't always be detected from data, so read the items.

## Picks up

- Long to wide, item means, sum scores, item–total correlations (from `irw-data`).
- Constructs; a scale is meant to measure one thing (from `constructs`).
- Keying: already-reversed items in the Mini-IPIP (from `irw-data`).

## Promises / leaves open

- Alpha ≤ reliability needs tau-equivalence → `fa-confirmatory` (omega), `ctt-limits` (how loose the bound can be).
- One SEM for everyone → `information` (conditional SEM), `score-meaning` (error bands).
- CTT says nothing about item responses → `ctt-limits`, `rasch`.
- Correlated errors (shared passages) make alpha overstate → `dimensionality`, `explanatory-irt`.
- Alpha is not unidimensionality → `fa-exploratory`.
- Reliability is a property of scores in a population (the reliability paradox) → `g-theory`, `validity-evidence`.
- Reverse keying → `fa-exploratory`, `polytomous`, `instrument-building`.
- Many sources of error at once → `g-theory`.
- Attenuation (problem 2) → `validity-evidence`, `sem`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `gilbert_meta_1` | main example | MORE reading RCT outcome, 30 items, 7,322 complete cases. Item-rest correlations mostly 0.4–0.6; `s_read_7_4` near zero. Split halves average to alpha. | — |
| `lessR_Mach4` | contrast | Unkeyed alpha 0.37 with small positive item-rest correlations; keyed by the published key, 0.70. m19 still doesn't fit. | — |

## Widget / simulation / problem ideas

**Widgets**
- Parallel forms: simulated forms with adjustable true and error variance; the correlation tracks reliability; SEM shown (idea 2).
- When does alpha equal reliability? Six items with loadings pulled apart (idea 3).
- Lengthening a test: Spearman–Brown curve (idea 4).

**Predict-then-check:** the Mach IV is half reverse-worded; before keying, what will alpha and the item-rest correlations look like? Answered by the unkeyed analysis.

**Simulate:** six-item classical model; true reliability vs. alpha with equal and then unequal loadings (base R).

**Problems**
1. Derivation: parallel forms correlation; where each assumption is used.
2. Derivation: attenuation, and the bound on validity (Lord & Novick ch. 1).
3. Real data with a twist: drop `s_read_7_4`; compare with the Spearman–Brown prediction.
4. Judgment: why alpha isn't below every split half; challenge (open): are the low splits non-parallel?
5. Judgment / design: the two weakest keyed Mach IV items: drop, rewrite or keep? Research vs. screening.
6. Real data: alpha at scale for five 0/1 tables; predict, then explain.

## Go deeper

- **Alpha is a lower bound on reliability (in the page).** Equality under essential tau-equivalence; fails with correlated errors. Why: `fa-confirmatory` (omega), `ctt-limits`, `g-theory`. Length: about a page.
- **Parallel forms ⇒ reliability (candidate).** Currently problem 1; the depth pass (#10) decides whether it becomes a callout.

## Open questions

- None new. Ben's verdict on alpha is pending in the page (#3, tracked in #62).
- Thread check: problem 6 ("alpha at scale") overlaps deep dive #20 (alpha across hundreds of tables). Keep the problem as the small version?
